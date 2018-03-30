<?php

namespace Tests\Unit;

use Tests\TestCase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\RedashUrlGenerator;

class RedashUrlGeneratorTest extends TestCase
{
    public function testIframe()
    {
        config()->set('services.redash.base_url', 'http://localhost:5000');
        config()->set('services.redash.api_key', 'TEST_API_KEY');

        $class = \App::make(RedashUrlGenerator::class);

        $this->assertEquals(
            '<iframe src="http://localhost:5000/embed/query/1/visualization/2?api_key=TEST_API_KEY" width="1070" height="500"></iframe>',
            $class->iframe(1, 2)
        );

        $this->assertEquals(
            '<iframe src="http://localhost:5000/embed/query/1/visualization/2?api_key=TEST_API_KEY" width="3" height="4"></iframe>',
            $class->iframe(1, 2, ['width' => 3, 'height' => 4])
        );
    }
}
