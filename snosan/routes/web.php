<?php

Route::get('/', 'HomeController@index')->name('home');
Route::get('/dashboard', 'DashboardController@index')->name('dashboard.index');

Auth::routes();
