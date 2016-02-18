'use strict'

MainModule.service 'LocalStorage', ($window) ->
    class LocalStorage

        @storage = null;

        # конструктор
        # -----------
        # `type` - тип хранилища ('sessionStorage', 'localStorage')
        constructor: (type) ->
            @storage = $window[type];


        setItem: (name, item) ->
            if angular.isObject(item) || angular.isArray(item)
                item = angular.toJson(item);
            @storage.setItem(name, item);


        getItem: (name, item) ->
            item = @storage.getItem(name);

            try
                item = angular.fromJson(item);
            catch e
                console.log(e);
            item;


        removeItem: (item) ->
            @storage.removeItem(item);


        removeAllItem: () ->
            @storage.clear();


    storage = new LocalStorage('localStorage');
    return storage;
