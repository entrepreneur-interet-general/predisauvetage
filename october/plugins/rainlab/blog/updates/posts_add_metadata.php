<?php

namespace RainLab\Blog\Updates;

use October\Rain\Database\Updates\Migration;
use Schema;

class posts_add_metadata extends Migration
{
    public function up()
    {
        if (Schema::hasColumn('rainlab_blog_posts', 'metadata')) {
            return;
        }

        Schema::table('rainlab_blog_posts', function ($table) {
            $table->mediumText('metadata')->nullable();
        });
    }

    public function down()
    {
        if (Schema::hasColumn('rainlab_blog_posts', 'metadata')) {
            Schema::table('rainlab_blog_posts', function ($table) {
                $table->dropColumn('metadata');
            });
        }
    }
}
