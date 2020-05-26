<?php

return [
    'plugin' => [
        'name'        => 'Blog',
        'description' => 'Solidna platforma blogera',
    ],
    'blog' => [
        'menu_label'             => 'Blog',
        'menu_description'       => 'Zarządzaj postami na blogu',
        'posts'                  => 'Posty',
        'create_post'            => 'Utwórz post',
        'categories'             => 'Kategorie',
        'create_category'        => 'Utwórz kategorię',
        'tab'                    => 'Blog',
        'access_posts'           => 'Zarządzaj postami',
        'access_categories'      => 'Zarządzaj kategoriami na blogu',
        'access_other_posts'     => 'Zarządzaj postami innych użytkowników',
        'access_import_export'   => 'Zarządzaj importowaniem i eksportowaniem postów',
        'access_publish'         => 'Publikuj posty',
        'manage_settings'        => 'Zarządzaj ustawieniami bloga',
        'delete_confirm'         => 'Czy jesteś pewien?',
        'chart_published'        => 'Opublikowane',
        'chart_drafts'           => 'Szkice',
        'chart_total'            => 'Łącznie',
        'settings_description'   => 'Zarządzaj ustawieniami bloga',
        'show_all_posts_label'   => 'Pokaż wszystkie posty użytkownikom backendu',
        'show_all_posts_comment' => 'Wyświetl opublikowane i nieopublikowany posty na stronie dla użytkowników backendu',
        'tab_general'            => 'Ogólne',
    ],
    'posts' => [
        'list_title'       => 'Zarządzaj postami',
        'filter_category'  => 'Kategoria',
        'filter_published' => 'Ukryj opublikowane',
        'filter_date'      => 'Date',
        'new_post'         => 'Nowy post',
        'export_post'      => 'Eksportuj posty',
        'import_post'      => 'Importuj posty',
    ],
    'post' => [
        'title'                  => 'Tytuł',
        'title_placeholder'      => 'Tytuł nowego posta',
        'content'                => 'Zawartość',
        'content_html'           => 'Zawartość HTML',
        'slug'                   => 'Alias',
        'slug_placeholder'       => 'alias-nowego-postu',
        'categories'             => 'Kategorie',
        'author_email'           => 'Email autora',
        'created'                => 'Utworzony',
        'created_date'           => 'Data utworzenia',
        'updated'                => 'Zaktualizowany',
        'updated_date'           => 'Data aktualizacji',
        'published'              => 'Opublikowany',
        'published_date'         => 'Data publikacji',
        'published_validation'   => 'Proszę określić datę publikacji',
        'tab_edit'               => 'Edytuj',
        'tab_categories'         => 'Kategorie',
        'categories_comment'     => 'Wybierz kategorie do których post należy',
        'categories_placeholder' => 'Nie ma żadnej kategorii, powinieneś utworzyć przynajmniej jedną.',
        'tab_manage'             => 'Zarządzaj',
        'published_on'           => 'Opublikowane',
        'excerpt'                => 'Zalążek',
        'summary'                => 'Summary',
        'featured_images'        => 'Załączone grafiki',
        'delete_confirm'         => 'Czy naprawdę chcesz usunąć ten post?',
        'delete_success'         => 'Posty zostały pomyślnie usunięte.',
        'close_confirm'          => 'Ten post nie jest zapisany.',
        'return_to_posts'        => 'Wróć do listy postów',
    ],
    'categories' => [
        'list_title'    => 'Zarządzaj kategoriami postów',
        'new_category'  => 'Nowa kategoria',
        'uncategorized' => 'Bez kategorii',
    ],
    'category' => [
        'name'                 => 'Nazwa',
        'name_placeholder'     => 'Nazwa nowej kategorii',
        'description'          => 'Opis',
        'slug'                 => 'Alias',
        'slug_placeholder'     => 'alias-nowej-kategorii',
        'posts'                => 'Posty',
        'delete_confirm'       => 'Czy naprawdę chcesz usunąć tę kategorię?',
        'delete_success'       => 'Kategorie zostały pomyślnie usunięte.',
        'return_to_categories' => 'Wróć do listy kategorii',
        'reorder'              => 'Zmień kolejnośc kategorii',
    ],
    'menuitem' => [
        'blog_category'       => 'Kategorie',
        'all_blog_categories' => 'Wszystkie kategorie',
        'blog_post'           => 'Post na bloga',
        'all_blog_posts'      => 'Wszystkie posty',
        'category_blog_posts' => 'Posty w kategorii',
    ],
    'settings' => [
        'category_title'                      => 'Lista kategorii',
        'category_description'                => 'Wyświetla listę blogowych kategorii na stronie.',
        'category_slug'                       => 'Alias kategorii',
        'category_slug_description'           => 'Look up the blog category using the supplied slug value. This property is used by the default component partial for marking the currently active category.',
        'category_display_empty'              => 'Pokaż puste kategorie',
        'category_display_empty_description'  => 'Pokazuje kategorie, które nie posiadają postów',
        'category_page'                       => 'Strona kategorii',
        'category_page_description'           => 'Nazwa strony kategorii gdzie są pokazywane linki. Ten parametr jest domyślnie używany przez komponent.',
        'post_title'                          => 'Post',
        'post_description'                    => 'Wyświetla pojedynczy post na stronie.',
        'post_slug'                           => 'Alias postu',
        'post_slug_description'               => 'Szuka post po nazwie aliasu.',
        'post_category'                       => 'Strona kategorii',
        'post_category_description'           => 'Nazwa strony kategorii gdzie są pokazywane linki. Ten parametr jest domyślnie używany przez komponent.',
        'posts_title'                         => 'Lista postów',
        'posts_description'                   => 'Wyświetla kilka ostatnich postów.',
        'posts_pagination'                    => 'Numer strony',
        'posts_pagination_description'        => 'Ta wartość odpowiada za odczytanie numeru strony.',
        'posts_filter'                        => 'Filtr kategorii',
        'posts_filter_description'            => 'Wprowadź alias kategorii lub adres URL aby filtrować posty. Pozostaw puste aby pokazać wszystkie.',
        'posts_per_page'                      => 'Ilość postów na strone',
        'posts_per_page_validation'           => 'Nieprawidłowa wartość ilości postów na strone',
        'posts_no_posts'                      => 'Komunikat o braku postów',
        'posts_no_posts_description'          => 'Wiadomość, która ukaże się kiedy komponent nie odnajdzie postów. Ten parametr jest domyślnie używany przez komponent.',
        'posts_no_posts_default'              => 'Nie znaleziono postów',
        'posts_order'                         => 'Kolejność postów',
        'posts_order_description'             => 'Parametr przez który mają być sortowane posty',
        'posts_category'                      => 'Strona kategorii',
        'posts_category_description'          => 'Nazwa strony kategorii w wyświetlaniu linków "Posted into" [Opublikowano w]. Ten parametr jest domyślnie używany przez komponent.',
        'posts_post'                          => 'Strona postu',
        'posts_post_description'              => 'Nazwa strony postu dla linków "Learn more" [Czytaj więcej]. Ten parametr jest domyślnie używany przez komponent.',
        'posts_except_post'                   => 'Wyklucz posty',
        'posts_except_post_description'       => 'Wprowadź ID/URL lub zmienną z ID/URL postu, który chcesz wykluczyć',
        'posts_except_post_validation'        => 'Wartość pola wykluczenia postów musi być pojedynczym ID/aliasem lub listą ID/aliasów rozdzieloną przecinkami',
        'posts_except_categories'             => 'Wyklucz kategorie',
        'posts_except_categories_description' => 'Wprowadź listę aliasów kategorii rozdzieloną przecinkami lub zmienną zawierającą taką listę',
        'posts_except_categories_validation'  => 'Wartośc pola wykluczenia kategorii musi być pojedynczym aliasem lub listą aliasów rozdzielonych przecinkami',
        'rssfeed_blog'                        => 'Strona bloga',
        'rssfeed_blog_description'            => 'Nazwa strony głównej bloga do generowania linków. Używane przez domyślny fragment komponentu.',
        'rssfeed_title'                       => 'Kanał RSS',
        'rssfeed_description'                 => 'Generuje kanał RSS zawierający posty z bloga.',
        'group_links'                         => 'Linki',
        'group_exceptions'                    => 'Wyjątki',
    ],
    'sorting' => [
        'title_asc'      => 'Tytuł (rosnąco)',
        'title_desc'     => 'Tytuł (malejąco)',
        'created_asc'    => 'Data utworzenia (rosnąco)',
        'created_desc'   => 'Data utworzenia (rosnąco)',
        'updated_asc'    => 'Data aktualizacji (rosnąco)',
        'updated_desc'   => 'Data aktualizacji (rosnąco)',
        'published_asc'  => 'Data publikacji (rosnąco)',
        'published_desc' => 'Data publikacji (rosnąco)',
        'random'         => 'Losowo',
    ],
    'import' => [
        'update_existing_label'          => 'Aktualizuj istniejące wpisy',
        'update_existing_comment'        => 'Zaznacz to pole, aby zaktualizować posty, które mają taki sam identyfikator (ID), tytuł lub alias.',
        'auto_create_categories_label'   => 'Utwórz kategorie podane w pliku',
        'auto_create_categories_comment' => 'Aby skorzystać z tej funkcji powinieneś dopasować kolumnę Kategorii. W przeciwnym wypadku wybierz domyślną kategorię do użycia poniżej.',
        'categories_label'               => 'Kategorie',
        'categories_comment'             => 'Wybierz kategorię, do której będą należeć zaimportowane posty (opcjonalne).',
        'default_author_label'           => 'Domyślny autor postów (opcjonalne)',
        'default_author_comment'         => 'Import spróbuje dopasować istniejącego autora na podstawie kolumny email. W przypadku niepowodzenia zostanie użyty autor wybrany powyżej.',
        'default_author_placeholder'     => '-- wybierz autora --',
    ],
];
