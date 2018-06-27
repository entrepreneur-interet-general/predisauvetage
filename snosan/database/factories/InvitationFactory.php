<?php

use Faker\Generator as Faker;

$factory->define(App\Invitation::class, function (Faker $faker) {
    return [
        'email'            => $faker->unique()->safeEmail,
        'invitation_token' => str_random(32),
    ];
});

$factory->state(App\Invitation::class, 'used', [
    'registered_at' => now()->subMinutes(5),
]);
