<?php

namespace App\Providers;

use App\RedashUrlGenerator;
use Illuminate\Support\ServiceProvider;

class RedashProvider extends ServiceProvider
{
    public function register()
    {
        $this->app->singleton(RedashUrlGenerator::class, function ($app) {
            return new RedashUrlGenerator(
                config('services.redash.base_url'),
                config('services.redash.api_key')
            );
        });
    }
}
