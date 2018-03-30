<?php
declare(strict_types=1);

namespace App;

class RedashUrlGenerator
{

    private $baseUrl;
    private $apiKey;

    const DEFAULT_WIDTH_PX = 1070;
    const DEFAULT_HEIGHT_PX = 500;

    public function __construct(string $baseUrl, $apiKey)
    {
        $this->baseUrl = $baseUrl;
        $this->apiKey = $apiKey;
    }

    public function iframe(int $queryId, int $visualisationId, array $options=[])
    {
        $template = '<iframe src="%s/embed/query/%s/visualization/%s?%s" width="%s" height="%s"></iframe>';

        $width = array_get($options, 'width', self::DEFAULT_WIDTH_PX);
        $height = array_get($options, 'height', self::DEFAULT_HEIGHT_PX);

        $queryString = http_build_query(['api_key' => $this->apiKey]);

        return sprintf($template, $this->baseUrl, $queryId, $visualisationId, $queryString, $width, $height);
    }
}
