<?php

namespace App\Http\Middleware;

use App\Invitation;
use Closure;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class HasInvitation
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure                 $next
     *
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if ($request->isMethod('get')) {
            if (!$request->has('invitation_token')) {
                flash("L'inscription ne peut se faire que par invitation.")->error();

                return redirect(route('home'));
            }

            $invitation_token = $request->get('invitation_token');

            try {
                $invitation = Invitation::where('invitation_token', $invitation_token)->firstOrFail();
            } catch (ModelNotFoundException $e) {
                flash("Votre lien d'invitation n'est pas valide.")->error();

                return redirect(route('home'));
            }

            if (!is_null($invitation->registered_at)) {
                flash("Votre lien d'invitation a déjà été utilisé.")->error();

                return redirect(route('login'));
            }
        }

        return $next($request);
    }
}
