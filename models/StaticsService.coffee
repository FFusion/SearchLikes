###
#StaticsService#
Сервис статистики
###

'use strict';

MainModule.service 'Static', ($timeout, $q, RestModel,Loader) ->
    class Static

        resultFriends: [],
        params:null

        # статистика по кол-ву друзей
        getListCountFriends: (friends) ->
            if friends.length > 25
                tempFriendsArray = friends.splice(0,25);
                $timeout(()=>
                    RestModel.getAllCountFriends(tempFriendsArray, @params).then(
                        (data)=>
                            angular.forEach(data.response, (user)=>
                                @resultFriends.push(user[0]);
                            )
                            @getListCountFriends(friends);
                        (error)->
                            console.log(error);
                    )
                ,330)
            else
                if friends.length != 0
                    $timeout(()=>
                        RestModel.getAllCountFriends(friends, @params).then(
                            (data)=>
                                angular.forEach(data.response, (user)=>
                                    @resultFriends.push(user[0]);
                                )

                                @resultFriends = @resultFriends.sort(@sortableFriends);
                                @resultFriends = Loader.renderBand(@resultFriends);

                                return @resultFriends;
                        )
                    ,330)
                else
                    console.log('dct');


        sortableFriends: (a,b) ->
            return b.counters.friends - a.counters.friends;


    new Static();


