<?php

namespace App\Providers\Filament;

use App\Enums\FormTypeEnum;
use App\Filament\Partner\Pages\Login;
use App\Filament\Partner\Pages\Register;
use App\Filament\Partner\Resources\SimulationResource;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationBuilder;
use Filament\Navigation\NavigationGroup;
use Filament\Navigation\NavigationItem;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Filapanel\ClassicTheme\ClassicThemePlugin;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Support\Facades\Route;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class PartnerPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->darkMode()
            ->favicon('https://criawebstudio.com.br/wp-content/uploads/2025/03/favicon-maua.png')
            ->brandLogo('https://criawebstudio.com.br/wp-content/uploads/2025/03/maua-branco.png')
            ->brandLogoHeight('2.5rem')
            ->profile()
            ->id('partner')
            ->login(Login::class)
            ->registration(Register::class)
            ->passwordReset()
            ->path('/')
            ->colors([
                'primary' => Color::Amber,
            ])
            ->discoverResources(in: app_path('Filament/Partner/Resources'), for: 'App\\Filament\\Partner\\Resources')
            ->discoverPages(in: app_path('Filament/Partner/Pages'), for: 'App\\Filament\\Partner\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Partner/Widgets'), for: 'App\\Filament\\Partner\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
            ])
            ->routes(function () {
                return [
                    Route::post('login', static fn () => dd('login'))
                ];
            })
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->navigation(fn(NavigationBuilder $builder) => self::navigations($builder))
            ->authMiddleware([
                Authenticate::class,
            ])
            ->plugin(ClassicThemePlugin::make());
    }

    public static function navigations(NavigationBuilder $builder): NavigationBuilder
    {
        $builder->items([
            ...Pages\Dashboard::getNavigationItems()
        ]);

        $route = SimulationResource::getRouteBaseName();

        $simulations = NavigationGroup::make('Simulações')
            ->items([
                NavigationItem::make(SimulationResource::getNavigationLabel())
                    ->icon(SimulationResource::getNavigationIcon())
                    ->isActiveWhen(fn () => request()->routeIs(SimulationResource::getRouteBaseName() . '.index'))
                    ->url(SimulationResource::getNavigationUrl()),
                NavigationItem::make('Consulta CPF/CNPJ')
                    ->isActiveWhen(fn () => request()?->routeIs(SimulationResource::getRouteBaseName() . '.search-document'))
                    ->url(SimulationResource::getUrl('search-document')),
                NavigationItem::make(FormTypeEnum::REAL_ESTATE_CREDIT->getLabel())
                    ->isActiveWhen(fn () => request()?->routeIs(sprintf("%s.%s", $route, FormTypeEnum::REAL_ESTATE_CREDIT->value)))
                    ->url(SimulationResource::getUrl(FormTypeEnum::REAL_ESTATE_CREDIT->value)),
                NavigationItem::make(FormTypeEnum::CREDIT_PROPERTY_GUARANTEE->getLabel())
                    ->isActiveWhen(fn () => request()?->routeIs(sprintf("%s.%s", $route, FormTypeEnum::CREDIT_PROPERTY_GUARANTEE->value)))
                    ->url(SimulationResource::getUrl(FormTypeEnum::CREDIT_PROPERTY_GUARANTEE->value)),
                NavigationItem::make(FormTypeEnum::CONSORTIUM->getLabel())
                    ->isActiveWhen(fn () => request()?->routeIs(sprintf("%s.%s", $route, FormTypeEnum::CONSORTIUM->value)))
                    ->url(SimulationResource::getUrl(FormTypeEnum::CONSORTIUM->value))
            ]);

        $builder->groups([
            $simulations
        ]);

        return $builder;
    }
}
