<?php

namespace Tests\Feature;

use App\Invitation;
use App\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

class RegisterTest extends TestCase
{
    use DatabaseTransactions;

    public function testRegisterFormDisplayed()
    {
        $token = factory(Invitation::class)->create()->invitation_token;

        $response = $this->get('/register?invitation_token='.$token);

        $response->assertStatus(200);
    }

    public function testRegisterFormWithoutInvitation()
    {
        $response = $this->get('/register');

        $response->assertRedirect(route('home'));
    }

    public function testRegistersAValidUser()
    {
        $invitation = factory(Invitation::class)->create();

        $response = $this->post('register', [
            'name'                  => 'Jane Doe',
            'email'                 => $invitation->email,
            'password'              => 'secret',
            'password_confirmation' => 'secret',
        ]);

        $response->assertStatus(302);

        $this->assertAuthenticated();
    }

    public function testDoesNotRegisterAUsedInvitation()
    {
        $invitation = factory(Invitation::class)->states('used')->create();

        $response = $this->post('register', [
            'name'                  => 'Jane Doe',
            'email'                 => $invitation->email,
            'password'              => 'secret',
            'password_confirmation' => 'secret',
        ]);

        $response->assertStatus(302);

        $this->assertGuest();
    }

    public function testDoesNotRegisterAnInvalidUser()
    {
        $user = factory(User::class)->make();

        $response = $this->post('register', [
            'name'                  => $user->name,
            'email'                 => $user->email,
            'password'              => 'secret',
            'password_confirmation' => 'invalid',
        ]);

        $response->assertSessionHasErrors('password');

        $this->assertGuest();
    }
}
