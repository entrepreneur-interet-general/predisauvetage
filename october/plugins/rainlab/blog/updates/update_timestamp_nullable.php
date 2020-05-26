<?php

namespace RainLab\Blog\Updates;

use DbDongle;
use October\Rain\Database\Updates\Migration;

class update_timestamp_nullable extends Migration
{
    public function up()
    {
        DbDongle::disableStrictMode();

        DbDongle::convertTimestamps('rainlab_blog_posts');
        DbDongle::convertTimestamps('rainlab_blog_categories');
    }

    public function down()
    {
        // ...
    }
}
