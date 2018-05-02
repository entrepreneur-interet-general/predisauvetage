<?php

Route::get('/', 'HomeController@index')->name('home');
Route::get('/dashboard', 'DashboardController@index')->name('dashboard.index');
Route::get('/docs/{format}', 'CircleController@latestDocumentationHtml')->where('format', '(html|md)');

Auth::routes();
