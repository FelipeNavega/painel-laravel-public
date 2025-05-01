<?php

namespace App\Filament\Partner\Pages;

use App\Enums\PartnerTypeEnum;
use App\Enums\UserTypeEnum;
use DanHarrin\LivewireRateLimiting\Exceptions\TooManyRequestsException;
use Filament\Events\Auth\Registered;
use Filament\Facades\Filament;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Http\Responses\Auth\Contracts\RegistrationResponse;
use Filament\Notifications\Notification;
use Filament\Support\RawJs;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\HtmlString;

class Register extends \Filament\Pages\Auth\Register
{
    public function register(): ?RegistrationResponse
    {
        try {
            $this->rateLimit(2);
        } catch (TooManyRequestsException $exception) {
            Notification::make()
                ->title(__('filament-panels::pages/auth/register.notifications.throttled.title', [
                    'seconds' => $exception->secondsUntilAvailable,
                    'minutes' => ceil($exception->secondsUntilAvailable / 60),
                ]))
                ->body(array_key_exists('body', __('filament-panels::pages/auth/register.notifications.throttled') ?: []) ? __('filament-panels::pages/auth/register.notifications.throttled.body', [
                    'seconds' => $exception->secondsUntilAvailable,
                    'minutes' => ceil($exception->secondsUntilAvailable / 60),
                ]) : null)
                ->danger()
                ->send();

            return null;
        }

        $user = DB::transaction(function () {
            $data = $this->form->getState();
            $data['type'] = UserTypeEnum::PARTNER;

            return $this->getUserModel()::create($data);
        });

        event(new Registered($user));

        $this->sendEmailVerificationNotification($user);

        Notification::make()
            ->title(trans('notification.new_register.title'))
            ->body(trans('notification.new_register.body'))
            ->success()
            ->send();

        return app(RegistrationResponse::class);
    }

    /**
     * @return array<int | string, string | Form>
     */
    protected function getForms(): array
    {
        return [
            'form' => $this->form(
                $this->makeForm()
                    ->schema([
                        $this->getNameFormComponent(),
                        $this->getEmailFormComponent(),
                        TextInput::make('social_name')
                            ->label('general.social_name')->translateLabel(),
                        TextInput::make('document')
                            ->label('forms.document')->translateLabel()
                            ->required()
                            ->rules([
                                function () {
                                    return static function (string $attribute, $value, \Closure $fail) {
                                        $value = preg_replace('/\D/', '', $value);
                                        if (strlen($value) !== 11 && strlen($value) !== 14) {
                                            $fail('O documento é invalido');
                                        }
                                    };
                                },
                            ])
                            ->mask(RawJs::make(<<<'JS'
                        $input.replaceAll(/\D/g, '').length <= 11 ? '999.999.999-99' : '99.999.999/9999-99'
                    JS
                            )),
                        TextInput::make('phone')
                            ->label('forms.phone')->translateLabel()
                            ->columnSpanFull()
                            ->required()
                            ->mask(RawJs::make(<<<'JS'
                        $input.replaceAll(/\D/g, '').length <= 10 ? '(99) 9999-9999' : '(99) 99999-9999'
                    JS
                            )),
                        Select::make('partner_type')
                            ->required()
                            ->label('forms.questions.partner_type')->translateLabel()
                            ->options(PartnerTypeEnum::class),
                        $this->getPasswordFormComponent(),
                        $this->getPasswordConfirmationFormComponent(),

                        Checkbox::make('accept_terms_and_conditions')
                            ->required()
                            ->label($this->termConditions())
                    ])
                    ->statePath('data'),
            ),
        ];
    }

    private function termConditions(): HtmlString
    {
        $url = Blade::render(<<<'Blade'
    @include('filament::components.link', [
        'href' => 'https://www.simulaimoveis.com.br/contrato-de-parceria',
        'slot' => 'Contrato de Parceria',
        'target' => '_blank',
    ])
Blade);

        return new HtmlString(sprintf("Li e aceito os termos do %s", $url));
    }
}
