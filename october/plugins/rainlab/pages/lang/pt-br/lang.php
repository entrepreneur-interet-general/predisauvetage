<?php

return [
    'plugin' => [
        'name'        => 'Páginas',
        'description' => 'Gerenciar páginas e menus.',
    ],
    'page' => [
        'menu_label'            => 'Páginas',
        'template_title'        => '%s Páginas',
        'delete_confirmation'   => 'Tem certeza que deseja excluir as páginas selecionadas? Todas as subpáginas também serão excluídas.',
        'no_records'            => 'Nenhuma página encontrada',
        'delete_confirm_single' => 'Tem certeza que deseja excluir a página selecionada? Todas as subpáginas também serão excluídas.',
        'new'                   => 'Nova página',
        'add_subpage'           => 'Adicionar subpágina',
        'invalid_url'           => 'Formato inválido de URL. A URL deve iniciar com o símbolo / e pode conter apenas dígitos, letras latinas e os seguintes símbolos: _-/.',
        'url_not_unique'        => 'Esta URL já está sendo utilizada por outra página.',
        'layout'                => 'Layout',
        'layouts_not_found'     => 'Nenhum layout encontrado',
        'saved'                 => 'Página salva com sucesso.',
        'tab'                   => 'Páginas',
        'manage_pages'          => 'Gerenciar páginas estáticas',
        'manage_menus'          => 'Gerenciar menus estáticos',
        'access_snippets'       => 'Acessar fragmentos',
        'manage_content'        => 'Gerenciar conteúdos estáticos',
    ],
    'menu' => [
        'menu_label'            => 'Menus',
        'delete_confirmation'   => 'Tem certeza que deseja excluir os menus selecionados?',
        'no_records'            => 'Nenhum menu encontrado',
        'new'                   => 'Novo menu',
        'new_name'              => 'Novo menu',
        'new_code'              => 'novo-menu',
        'delete_confirm_single' => 'Tem certeza que deseja excluir este menu?',
        'saved'                 => 'Menu salvo com sucesso.',
        'name'                  => 'Nome',
        'code'                  => 'Código',
        'items'                 => 'Itens do menu',
        'add_subitem'           => 'Adicionar subitem',
        'no_records'            => 'Nenhum item encontrado',
        'code_required'         => 'O código é necessário',
        'invalid_code'          => 'Formato inválido de código. O código pode conter dígitos, letras latinas e os seguintes símbolos: _-',
    ],
    'menuitem' => [
        'title'                      => 'Título',
        'editor_title'               => 'Editar item',
        'type'                       => 'Tipo',
        'allow_nested_items'         => 'Permitir itens aninhados',
        'allow_nested_items_comment' => 'Itens aninhados podem ser gerados dinamicamente por páginas estáticas e outros tipos de itens',
        'url'                        => 'URL',
        'reference'                  => 'Referência',
        'title_required'             => 'O título é necessário',
        'unknown_type'               => 'Tipo de item desconhecido',
        'unnamed'                    => 'Item de menu sem nome',
        'add_item'                   => 'Adicionar <u>i</u>tem',
        'new_item'                   => 'Novo item',
        'replace'                    => 'Substituir este item com seus filhos gerados',
        'replace_comment'            => 'Use esta opção para empurrar os itens de menu gerados para o mesmo nível que este item. Este item em si será ocultado.',
        'cms_page'                   => 'Página CMS',
        'cms_page_comment'           => 'Selecione uma página para abrir quando o item for clicado.',
        'reference_required'         => 'A referência do item é necessária.',
        'url_required'               => 'A URL é necessária',
        'cms_page_required'          => 'Por favor, selecione uma página CMS',
        'code'                       => 'Código',
        'code_comment'               => 'Entre com o código do item se deseja acessar com a API.',
    ],
    'content' => [
        'menu_label'       => 'Conteúdo',
        'cant_save_to_dir' => 'Não é permitido salvar arquivos de conteúdo no diretório de páginas estáticas.',
    ],
    'sidebar' => [
        'add'    => 'Adicionar',
        'search' => 'Buscar...',
    ],
    'object' => [
        'invalid_type' => 'Tipo de objeto desconhecido',
        'not_found'    => 'O objeto requisitado não foi encontrado.',
    ],
    'editor' => [
        'title'                     => 'Título',
        'new_title'                 => 'Título da nova página',
        'content'                   => 'Conteúdo',
        'url'                       => 'URL',
        'filename'                  => 'Nome do arquivo',
        'layout'                    => 'Layout',
        'description'               => 'Descrição',
        'preview'                   => 'Visualizar',
        'enter_fullscreen'          => 'Entrar no modo tela cheia',
        'exit_fullscreen'           => 'Sair do modo tela cheia',
        'hidden'                    => 'Ocultar',
        'hidden_comment'            => 'Páginas ocultas são acessíveis apenas para administradores.',
        'navigation_hidden'         => 'Ocultar na navegação',
        'navigation_hidden_comment' => 'Marque esta opção para ocultar esta página de menus gerados automaticamente e itens de hierarquia de navegação.',
    ],
    'snippet' => [
        'partialtab'            => 'Fragmentos',
        'code'                  => 'Código do fragmento',
        'code_comment'          => 'Entre com o código para disponibilizar este bloco como um fragmento nas páginas estáticas.',
        'name'                  => 'Nome',
        'name_comment'          => 'O nome é exibido na lista de fragmentos no menu lateral na área de páginas estáticas e nas páginas em que o fragmento é adicionado.',
        'no_records'            => 'Nenhum fragmento encontrado',
        'menu_label'            => 'Fragmentos',
        'column_property'       => 'Título da propriedade',
        'column_type'           => 'Tipo',
        'column_code'           => 'Código',
        'column_default'        => 'Padrão',
        'column_options'        => 'Opções',
        'column_type_string'    => 'Texto',
        'column_type_checkbox'  => 'Caixa de seleção',
        'column_type_dropdown'  => 'Caixa de seleção suspensa',
        'not_found'             => 'Fragmento com o código :code não foi encontrado.',
        'property_format_error' => 'Código da propriedade deve iniciar com uma letra latina e pode conter apenas letras latinas e dígitos',
        'invalid_option_key'    => 'Chave de opção inválida: %s. Chaves de opção podem conter apenas dígitos, letras latinas e os caracteres _ e -',
    ],
];
