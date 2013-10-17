#
# Ideal Select
#
let $ = jQuery, doc = document, win = window

  plugin = {}

  plugin.name = \idealselect

  plugin.methods =

    _init: ->
      @select$ = $ @el
      @options$ = @select$.find \option

      @select$
        .css position: \absolute, left: \-9999px
        .attr \tabindex -1

      @_build!
      @_events!


    _build: ->
      default$ = @options$.filter \:selected

      @items$ = $ do
        @options$
          .map -> "<li>#{$ @ .text!}</li>"
          .get!join ''

      @items$.eq default$.index! .add-class \selected

      @title$ = $ """
        <a href="#" class="title" tabindex="-1">
          <span>#{default$.text!}</span>
          <i/>
        </a>
      """

      @dropdown$ = $ '<ul class="dropdown"></ul>' .append @items$

      @idealselect$ = $ do
        """
        <div class="idealselect" tabindex="0">
          <ul>
            <li></li>
          </ul>
        </div>
        """

      @idealselect$
        .find \li .append @title$, @dropdown$
        .end!insert-after @select$


    _update: (index) ->
      @options$.eq index .prop \selected true
      @idealselect$.find '.title span' .text (@items$.eq index .text!)
      @items$.remove-class \selected .eq index .add-class \selected


    _scroll: (index) ->
      if index
        item$ = @items$.eq index
        height = @dropdown$.height!
        position = item$.position!top

        if position >= height
          item$.get 0 .scroll-into-view!

        if position < 0
          item$.get 0 .scroll-into-view false
      else
        @items$.filter \.selected .get 0 .scroll-into-view!


    _events: ->
      @select$.change (e) ~>
        @_update ($ e.target .find \:selected .index!)

      @title$.click (e) ~>
        e.prevent-default!
        @idealselect$.focus!toggle-class \open
        @_scroll!

      @items$.click (e) ~>
        @_update ($ e.target .index!)
        @idealselect$.remove-class \open
        @select$.change!

      @idealselect$
        .mousedown (.prevent-default!)

        .focus ~> @select$.trigger-handler \focus

        .blur ~>
          @idealselect$.remove-class \open
          @select$.blur!

        .keydown (e) ~>
          index = @options$.filter \:selected .index!

          switch e.which
            # Enter
            when 13 => @idealselect$.toggle-class \open

            # Arrows
            when 38 => index = index-1 if index-1 > -1
            when 40 => index = index+1 if index+1 < @items$.length

            # Letter
            else
              letter = String.from-char-code e.which

              if letter is /\w/
                matches$ = @items$.filter -> ($ @ .text!index-of letter) is 0

                first = matches$.index!

                next = matches$.slice do
                  (matches$.index matches$.filter \.selected) + 1
                  matches$.length
                .index!

                index = if next > -1 then next else first

                scroll-now = true

          if index > -1
            @_update index
            @_scroll if scroll-now then 0 else index
            @select$.change!

          # Prevent window scroll
          $ doc .one \keydown (e) ->
            e.prevent-default! if e.which is 38 or e.which is 40


  (require \./plugin) plugin
