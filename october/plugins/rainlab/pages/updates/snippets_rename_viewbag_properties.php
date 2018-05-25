<?php

namespace RainLab\User\Updates;

use Cms\Classes\Partial;
use Cms\Classes\Theme;
use File;
use October\Rain\Database\Updates\Migration;

class snippets_rename_viewbag_properties extends Migration
{
    public function up()
    {
        $themes = Theme::all();
        foreach ($themes as $theme) {
            $partials = Partial::inTheme($theme)->all();
            foreach ($partials as $partial) {
                try {
                    $path = $partial->getFilePath();
                    $contents = File::get($path);
                    if (strpos($contents, 'staticPageSnippetCode') === false) {
                        continue;
                    }
                    $contents = str_replace('staticPageSnippetName', 'snippetName', $contents);
                    $contents = str_replace('staticPageSnippetCode', 'snippetCode', $contents);
                    $contents = str_replace('staticPageSnippetProperties', 'snippetProperties', $contents);
                    File::put($path, $contents);
                } catch (\Exception $ex) {
                    continue;
                }
            }
        }
    }

    public function down()
    {
    }
}
