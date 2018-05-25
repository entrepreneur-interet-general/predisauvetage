<?php

namespace RainLab\Pages\FormWidgets;

use Backend\Classes\FormWidgetBase;
use Input;
use Lang;
use RainLab\Pages\Classes\MenuItem;
use Str;

/**
 * Menu item reference search.
 *
 * @author Alexey Bobkov, Samuel Georges
 */
class MenuItemSearch extends FormWidgetBase
{
    use \Backend\Traits\SearchableWidget;

    public $searchPlaceholderMessage = 'rainlab.pages::lang.menuitem.search_placeholder';

    /**
     * Renders the widget.
     *
     * @return string
     */
    public function render()
    {
        return $this->makePartial('body');
    }

    /*
     * Event handlers
     */
    public function onSearch()
    {
        $this->setSearchTerm(Input::get('term'));

        return $this->getData();
    }

    /*
     * Methods for internal use
     */
    protected function getData()
    {
        return [
            'results' => $this->getMatches(),
        ];
    }

    protected function getMatches()
    {
        $searchTerm = Str::lower($this->getSearchTerm());
        if (!strlen($searchTerm)) {
            return [];
        }

        $words = explode(' ', $searchTerm);

        $types = [];
        $item = new MenuItem();
        foreach ($item->getTypeOptions() as $type => $typeTitle) {
            $typeInfo = MenuItem::getTypeInfo($type);
            if (empty($typeInfo['references'])) {
                continue;
            }

            $typeMatches = [];
            foreach ($typeInfo['references'] as $key => $referenceInfo) {
                $title = is_array($referenceInfo) ? $referenceInfo['title'] : $referenceInfo;

                if ($this->textMatchesSearch($words, $title)) {
                    $typeMatches[] = [
                        'id'   => "$type::$key",
                        'text' => $title,
                    ];
                }
            }

            if (!empty($typeMatches)) {
                $types[] = [
                    'text'     => trans($typeTitle),
                    'children' => $typeMatches,
                ];
            }
        }

        return $types;
    }
}
