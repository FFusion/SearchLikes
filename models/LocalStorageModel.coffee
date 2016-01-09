MainModule.factory 'LocalStorage', () ->
    class LocalStorage

    setItem: (name, item) ->
        if angular.isObject(item) || angular.isArray(item)
            item = angular.toJson(item);
        window.localStorage.setItem(name, item);

    getItem: (name, item) ->
        item = window.localStorage.getItem(name);

        try
            item = angular.fromJson(item);
        catch e
            console.log(e);
        item;

    removeAllItem: () ->
        window.localStorage.clear();
