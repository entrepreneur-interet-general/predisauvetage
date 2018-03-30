@extends('layouts.app')

@section('content')
<div class="container">
    <div class="card">
        <div class="card-body">
            @foreach($visualisations as $visualisation)
                {!! $visualisation !!}
            @endforeach
        </div>
    </div>
</div>
@endsection
