<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\RedashUrlGenerator;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index(RedashUrlGenerator $redashGenerator)
    {
        $visualisations = [
            $redashGenerator->iframe(1, 2)
        ];

        return view('dashboard.index', compact('visualisations'));
    }
}
