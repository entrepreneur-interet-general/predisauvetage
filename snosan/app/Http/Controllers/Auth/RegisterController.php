<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Invitation;
use App\User;
use Illuminate\Validation\Rule;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Register Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles the registration of new users as well as their
    | validation and creation. By default this controller uses a trait to
    | provide this functionality without requiring any additional code.
    |
    */

    use RegistersUsers;

    /**
     * Where to redirect users after registration.
     *
     * @var string
     */
    protected $redirectTo = '/';

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest');
        $this->middleware('hasInvitation')->only('showRegistrationForm');
    }

    /**
     * Get a validator for an incoming registration request.
     *
     * @param array $data
     *
     * @return \Illuminate\Contracts\Validation\Validator
     */
    protected function validator(array $data)
    {
        return Validator::make($data, [
            'name'     => 'required|string|max:255',
            'email'    => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users',
                Rule::exists('invitations', 'email')->where(function($query) {
                    $query->whereNull('registered_at');
                })
            ],
            'password' => 'required|string|min:6|confirmed',
        ]);
    }

    /**
     * Create a new user instance after a valid registration.
     *
     * @param array $data
     *
     * @return \App\User
     */
    protected function create(array $data)
    {
        return User::create([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => Hash::make($data['password']),
        ]);
    }

    /**
     * Override the application registration form. Get the email that has been associated with the invitation and
     * pass it to the view.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\Response
     */
    public function showRegistrationForm(Request $request)
    {
        $invitation_token = $request->get('invitation_token');
        $invitation = Invitation::where('invitation_token', $invitation_token)->firstOrFail();
        $email = $invitation->email;
        return view('auth.register', compact('email'));
    }

    /**
     * After user registered, update the invitation registered_at.
     *
     * @param $user
     */
    public function registered(Request $request, $user)
    {
        $invitation = Invitation::where('email', $user->email)->firstOrFail();
        $invitation->registered_at = $user->created_at;
        $invitation->save();
    }
}
