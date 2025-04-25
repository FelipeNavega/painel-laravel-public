<?php

namespace App\Providers\Filament;

use App\Enums\FormTypeEnum;
use App\Filament\Resources\SimulationResource;
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
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->favicon('https://criawebstudio.com.br/wp-content/uploads/2025/03/ico-2.png')
            ->brandLogo('https://criawebstudio.com.br/wp-content/uploads/2025/03/logo-7-2.png')
            ->brandLogoHeight('2.5rem')
//            ->darkMode()
            ->id('admin')
            ->path('/admin')
            ->authGuard('admin')
            ->profile()
            ->colors([
                'primary' => Color::Amber,
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
            ])
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
//            ->navigation(fn (NavigationBuilder $builder): NavigationBuilder => self::navigations($builder))
            ->authMiddleware([
                Authenticate::class,
            ])
            ->plugin(ClassicThemePlugin::make());
    }

    public static function navigations(NavigationBuilder $builder): NavigationBuilder
    {
        $builder->groups([
            NavigationGroup::make('Simulações')
                ->items([
                    ...SimulationResource::getNavigationItems(),
                    NavigationItem::make(FormTypeEnum::REAL_ESTATE_CREDIT->getLabel())
                        ->url(SimulationResource::getUrl('real_estate_credit'))

                ]),
        ]);

        $builder->items([
            ...Pages\Dashboard::getNavigationItems()
        ]);

        return $builder;
    }
}
