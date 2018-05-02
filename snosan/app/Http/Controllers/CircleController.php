<?php

namespace App\Http\Controllers;

use Cache;
use GuzzleHttp\Client as GuzzleClient;

class CircleController extends Controller
{
    public function latestDocumentationHtml($format)
    {
        return Cache::remember("doc-$format", 10, function () use ($format) {
            $body = $this->get('tree/master');
            $buildNumber = collect(json_decode($body, true))->first()['build_num'];
            $body = $this->get("$buildNumber/artifacts");
            $data = collect(json_decode($body, true));

            $url = $data->filter(function ($e) use ($format) {
                return $e['pretty_path'] == "schema.$format";
            })->first()['url'];

            return (new GuzzleClient())->get($url)->getBody()->getContents();
        });
    }

    private function get($url)
    {
        $client = new GuzzleClient();
        $base = 'https://circleci.com/api/v1.1/project/github/entrepreneur-interet-general/predisauvetage/';
        $response = $client->get($base.$url, ['headers' => ['Accept' => 'application/json']]);

        return $response->getBody()->getContents();
    }
}
