###
#LoaderService#
Сервис для отображения процесса загрузки.  
Подходит и для отображения процесса запроса.
###

'use strict';

MainModule.service 'Loader', ($rootScope) ->
    class Loader
        ID: null

        loaderContainer: $('<div class="loader"></div>'),
        loaderProgress : $('<div class="loader-progress"></div>'),

        # старт загрузки
        # --------------
        startLoad: () ->

            @ID = Math.round(Math.random() * 1000);
            if !$rootScope.loaders
                $rootScope.loaders = {};
            $rootScope.loaders[@ID] = true;

            if $rootScope.loaders[@ID]
                $('body').append(@loaderContainer.append(@loaderProgress.css('width', 0)));


        # процесс загрузки
        process:(increment) ->
            @loaderProgress.width(increment * @loaderProgress.offsetParent().width() / 100);


        # стоп загрузки
        # -------------
        stopLoad : () ->                        
            delete $rootScope.loaders[@ID];
            
            @loaderProgress.css('width', '100%');

            setTimeout(() =>
                @loaderProgress.css('opacity', 0);

                setTimeout(() =>
                    @loaderContainer.remove();
                    @loaderProgress.css('opacity', 1);
                , 350);
            , 350);

        # полоса % заполнения
        renderBand:(array) ->
            maxCount = array[0].counters.friends;
            temp = [];
            angular.forEach(array, (user, index)->
                if index < 99
                    user.width = user.counters.friends / maxCount * 100;
                    user.width = user.width + '%';
                    temp.push(user);
            );

            return temp;




    new Loader();