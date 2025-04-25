@php
    $brandName = filament()->getBrandName();
    $brandLogoHeight = filament()->getBrandLogoHeight() ?? '1.5rem';
    $hasDarkModeBrandLogo = filled(filament()->getDarkModeBrandLogo());

    $getLogoClasses = fn (bool $isDarkMode): string => \Illuminate\Support\Arr::toCssClasses([
        'fi-logo',
        'flex' => ! $hasDarkModeBrandLogo,
        'flex dark:hidden' => $hasDarkModeBrandLogo && (! $isDarkMode),
        'hidden dark:flex' => $hasDarkModeBrandLogo && $isDarkMode,
    ]);

    $logoStyles = "height: {$brandLogoHeight}";
@endphp

@capture($content, $isDarkMode = false)
    <img
        alt="{{ __('filament-panels::layout.logo.alt', ['name' => $brandName]) }}"
        src="https://criawebstudio.com.br/wp-content/uploads/2025/03/logo-7-2.png"
        {{
            $attributes
                ->class([$getLogoClasses($isDarkMode)])
                ->style([$logoStyles])
        }}
    />
@endcapture

{{ $content() }}

@if ($hasDarkModeBrandLogo)
    {{ $content(isDarkMode: true) }}
@endif 