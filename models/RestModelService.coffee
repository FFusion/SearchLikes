'use strict'

MainModule.factory 'RestModel', ($q, $http, vk) ->
    class RestModel

    getLinkAutorization: () ->
        url = vk.auth + '?client_id=' + vk.clientId + '&scope=friends,offline,photos,wall&redirect_uri=' + vk.redirectUri + '&display=page&response_type=token';
        url;

    _getLinkFriends: (params, userId = null) ->
        if userId isnt null then id = userId else id = params.user_id;
        url = vk.api + '/method/friends.get?user_id=' + id + '&v=5.8&access_token=' + params.access_token + '&order=name&fields=city,sex,online,last_seen,has_mobile,photo_50&callback=JSON_CALLBACK';
        url;

#    _getLinkFriendsOnline: (params) ->
#        url = vk.api + '/method/friends.getOnline?user_id=' + params.user_id + '&online_mobile=1&access_token=' + params.access_token + '&callback=JSON_CALLBACK';\
#        url;

    _getLinkUser: (id, params = null) ->
        #запрос на users.get
        if params is null
            url = vk.api + '/method/users.get?user_id=' + id + '&v=5.8&fields=sex,bdate,city,last_seen,country,photo_200_orig,photo_100,online,contacts,status,followers_count,relation,counters,relation&callback=JSON_CALLBACK'
        else
            url = vk.api + '/method/users.get?user_id=' + id + '&access_token=' + params.access_token + '&v=5.8&fields=sex,bdate,city,last_seen,country,photo_200_orig,photo_100,online,contacts,status,followers_count,relation,common_count,counters,timezone&callback=JSON_CALLBACK'
        url;

    _getLinkUserSimply: (id, params = null) ->
        #запрос на users.get(без параметров)
        if params is null
            url = vk.api + '/method/users.get?user_id=' + id + '&v=5.8&callback=JSON_CALLBACK';
        else
            url = vk.api + '/method/users.get?user_id=' + id + '&access_token=' + params.access_token + '&v=5.8&callback=JSON_CALLBACK';
        url;

#    _getLinkMessage: (id, params) ->
#        url = vk.api + '/method/messages.send?user_id=' + id + '&v=5.27&message=Hello&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
#        url;

    _getLinkDeleteUser: (id, params) ->
        url = vk.api + '/method/friends.delete?' + 'user_id=' + id + '&access_token=' + params.access_token + 'callback=JSON_CALLBACK';
        url;


    getParams: (url) ->
        listParams = {};
        reg;
        reg = url.replace(/[#&]+([^=&]+)=([^&]*)/gi, (m, key, value) ->
            listParams[key] = value;
        )

        listParams;


    getFriends: (params, userId = null) ->
        deferred = $q.defer();
        url = @_getLinkFriends(params, userId);
        $http.jsonp(url)
            .success((friends) ->
                deferred.resolve(friends);
            )
            .error((error) ->
                deferred.reject(error);
                console.log(error);
            );

        deferred.promise;


    _parseTime: (time) ->
#        console.log(time)
        currentTime = {};
        userTime = {};
        finishTime = {};
        monthArray = ['января', 'февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'];

        currentTime.day = parseFloat(moment().format('Do'));
        currentTime.month = parseFloat(moment().format('MM'));
        currentTime.year = moment().format('YYYY');
        currentTime.hours = moment().format('HH');
        currentTime.minute = moment().format('mm');

        userTime.day = parseFloat(moment.unix(time).format('Do'));
        userTime.month = parseFloat(moment.unix(time).format('MM'));
        userTime.year = moment.unix(time).format('YYYY');
        userTime.hours = moment.unix(time).format('HH');
#        console.log(userTime.hours);
        userTime.minute = moment.unix(time).format('mm');

        if currentTime.year != userTime.year then finishTime.year = userTime.year;
        if currentTime.month != userTime.month then finishTime.month = monthArray[userTime.month - 1] else finishTime.currentMonth = monthArray[currentTime.month - 1];
        if currentTime.day != userTime.day
            if (parseFloat(currentTime.day) - parseFloat(userTime.day)) == 1
                finishTime.day = 'вчера'
            else
                finishTime.day = userTime.day;
        if parseFloat(currentTime.hours) != parseFloat(userTime.hours)
            if (parseFloat(currentTime.hours) - parseFloat(userTime.hours) == 1) && !finishTime.day && !finishTime.month && !finishTime.year
#                console.log(currentTime.hours);
                finishTime.hours = 'час назад'
            else
                finishTime.hours = userTime.hours;
        if parseFloat(currentTime.minute) != parseFloat(userTime.minute)
            finishTime.minute = userTime.minute;
#            console.log(finishTime.minute);

        finishTime;

    _getLastEntry: (object) ->
        #todo: не все обрабатывает корректно... подумать над условиями
        time = '';
        if object.day == 'вчера' then time = 'вчера в ' + object.hours + '.' + object.minute;
        if object.hours == 'час назад' && !angular.isDefined(object.day) && !angular.isDefined(object.month) then time = 'час назад';
        if object.minute && !angular.isDefined(object.hours) && !angular.isDefined(object.day) then time = object.minute + ' минут назад'
        if object.minute && object.hours && object.hours != 'час назад' && !angular.isDefined(object.day) && !angular.isDefined(object.month) && !angular.isDefined(object.year) then time = 'сегодня в ' + object.hours + '.' + object.minute;
        if object.minute && object.hours && object.day && object.day != 'вчера' && !angular.isDefined(object.year) && !angular.isDefined(object.month) then time = object.day + ' ' + object.currentMonth + ' в ' + object.hours + '.' + object.minute;
        if object.minute && object.hours && object.day && object.day != 'вчера' && object.month && !angular.isDefined(object.year) then time = object.day + ' ' + object.month + ' в ' + object.hours + '.' + object.minute;
        if object.minute && object.hours && object.day && object.day != 'вчера' && object.month && object.year then time = object.day + ' ' + object.month + ' ' + object.year + ' года в ' + object.hours + '.' + object.minute;

        if time == '' then console.log(object);
        return time




    _transformObject: (object) ->
        object.forEach((user) =>
            if angular.isDefined(user.last_seen) && user.online != 1 && !angular.isDefined(user.deactivated)
                lastTime = user.last_seen.time;
                objectTime = @_parseTime(lastTime);
                user.last_seen = @_getLastEntry(objectTime);
            else if user.online == 1
                user.last_seen = 'online';
            else if user.deactivated == 'deleted' || user.deactivated = "banned"
                user.last_seen = 'удален'
        );

        object;



    isWorkingFriendsObject: (object) ->
        console.log(object);
        params = {};
        temp = {};

        if object.response.items
            temp = object.response.items;
            params = @_transformObject(temp);
        else
            params = object.response[0];

        params;


    filteredUsers: (users, type) ->
        scaningUsers = [];

        angular.forEach(users, (user)->
            if type == "male" && user.sex == 2 && !angular.isDefined(user.deactivated)
                scaningUsers.push(user);
            if type == "female" && user.sex == 1 && !angular.isDefined(user.deactivated)
                scaningUsers.push(user);
        );

        if type == "all"
            return users
        else
            return scaningUsers



    moreInfo: (id, params = null) ->
        deffered = $q.defer();
        userId = parseFloat(id);
        url = @_getLinkUser(userId, params);

        $http.jsonp(url)
            .success((user)->
                deffered.resolve(user);
            )
            .error((error) ->
                deffered.reject(error);
                console.log(error);
            );

        deffered.promise;


    getUserById: (id = null, params = null) ->
        deffered = $q.defer();
        userId = if id isnt null then parseFloat(id) else 1;
        url = @_getLinkUserSimply(userId, params);

        $http.jsonp(url)
        .success((user)->
                deffered.resolve(user);
            )
        .error((error) ->
                deffered.reject(error);
                console.log(error);
            );

        deffered.promise;



    # отправка сообщения
    sendMessage: (id, params) ->
        deffered = $q.defer();
        url = @_getLinkMessage(id, params);
        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;


    #удаление пользователя из списка друзей
    deleteUser: (id, params) ->
        deffered = $q.defer();
        url = @_getLinkDeleteUser(id, params);
        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;

    #работа со стеной
    getWallPost: (userId, params, count) ->
        deffered = $q.defer();
        url = vk.api + '/method/wall.get?' + 'owner_id=' + userId + '&count=' + count + '&filter=owner&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;


    getAllWallPost: (userId, params, count = null, offset = null) ->
        if count is null then count = 100;
        if offset is null then offset = 0;
        deffered = $q.defer();
        url = vk.api + '/method/wall.get?' + 'owner_id=' + userId + '&count=' + count + '&offset=' + offset + '&filter=owner&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;


    getLikes: (userId, params, postId, type) ->
        deffered = $q.defer();
        url = vk.api + '/method/likes.getList?' + 'owner_id=' + userId + '&item_id=' + postId + '&type=' + type + '&filter=likes&friend_only=0&count=1000&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;


    friendsOnlineOrDelete: (type = null, friends) ->
        friendsArray = [];

        if type == 'online'
            friends.forEach((friend)->
                if friend.online == 1 then friendsArray.push(friend);
            )
        if type == 'delete'
            friends.forEach((friend)->
                if angular.isDefined(friend.deactivated) then friendsArray.push(friend);
            )

        if type is null
            friends.forEach((friend)->
                if !angular.isDefined(friend.deactivated) then friendsArray.push(friend);
            );

        friendsArray;


    getPhoto: (userId, params, count, type) ->
        deffered = $q.defer();
        if type == "all"
            url = vk.api + '/method/photos.getAll?' + 'owner_id=' + userId + '&count=' + count + '&no_service_albums=1&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
        else
            url = vk.api + '/method/photos.get?' + 'owner_id=' + userId + '&album_id=' + type + '&rev=1&count=' + count + '&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
            .success((data)->
                    deffered.resolve(data);
                )
            .error((error)->
                    deffered.reject(error);
                );

        deffered.promise;

    getPhotoAll: (userId, params, count = null, offset = null) ->
        deffered = $q.defer();
        if count is null then count = 200;
        if offset is null then offset = 0;
        url = vk.api + '/method/photos.getAll?' + 'owner_id=' + userId + '&count=' + count + '&offset=' + offset + '&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data)->
            deffered.resolve(data);
        )
        .error((error)->
            deffered.reject(error);
        );

        deffered.promise;


    # не доступно для сайтов..
    getComment: (userId, post, params) ->
        deffered = $q.defer();

        url = vk.api + '/method/wall.getComments?' + 'owner_id=' + userId + '&post_id=' + post.id + '&extended=1&count=100&need_likes=1&v=5.28&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;

    getWish: (content) ->
        deffered = $q.defer();

        $http.post('mail.php', fio: content.fio, email: content.email, wish: content.wish)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            )

        deffered.promise;

    getWishUser: (id) ->
        deffered = $q.defer();

        $http.post('mail.php', fio: id, email: '', wish: '')
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            )

        deffered.promise;

    getLikesExecute: (userId, object, params, type) ->
        deffered = $q.defer();
        count = 0;
        code = 'return {';
        for i in [0..object.length - 1]
            if i != object.length - 1
                code = code + 'listLikes_' + object[i].id + ':API.likes.getList({"type":"' + type + '", "owner_id":' + object[i].owner_id + ',"item_id":' + object[i].id +  ',"friends_only":0, "count":1000}),';
            else
                code = code + 'listLikes_' + object[i].id + ':API.likes.getList({"type":"' + type + '", "owner_id":' + object[i].owner_id + ',"item_id":' + object[i].id + ',"friends_only":0, "count":1000})';

        code = code + '};';
        url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
            .success((data)->
                deffered.resolve(data);
            )
            .error((error)->
                deffered.reject(error);
            );

        deffered.promise;


    getCommentsCount: (userId, params, count = null, offset = null) ->
        deffered = $q.defer();
        if count is null then count = 1;
        if offset is null then offset = 0;
        url = vk.api + '/method/photos.getAllComments?owner_id=' + userId + '&count=' + count + '&offset=' + offset + '&access_token=' + params.access_token + '&v=5.5&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data)->
            deffered.resolve(data);
        )
        .error((error)->
            deffered.reject(error);
        );

        deffered.promise;

    getPhotosById: (photos) ->
        deffered = $q.defer();


        url = vk.api + '/method/photos.getById?photos=' + photos + '&v=5.5&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data)->
           deffered.resolve(data);
        )
        .error((error)->
            deffered.reject(error);
        );

        deffered.promise;


    getCommentsByPhoto: (photo, params) ->
        # только 100 комментариев
        deffered = $q.defer();

        url = vk.api + '/method/photos.getComments?owner_id=' + photo.owner_id + '&photo_id=' + photo.id + '&extended=1&v=5.5&count=100&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data) ->
            deffered.resolve(data);
        )
        .error((error) ->
            deffered.reject(error);
        );

        deffered.promise;


    getAllCountFriends: (arrayFriends, params) ->
        deffered = $q.defer();
        code = 'return {'
        for i in [0..arrayFriends.length - 1]
            if i != arrayFriends.length - 1
                code = code + 'CountFr' + arrayFriends[i].id + ':API.users.get({"fields":"counters,photo_50", "user_id":'+ arrayFriends[i].id + '}),';
            else
                code = code + 'CountFr' + arrayFriends[i].id + ':API.users.get({"fields":"counters,photo_50", "user_id":' + arrayFriends[i].id + '})';

        code = code + '};';
        url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data)->
            deffered.resolve(data);
        )
        .error((error)->
            deffered.reject(error);
        );

        deffered.promise;


    getGroupCurentUserAdmin: (currentId, params) ->
        deffered = $q.defer();

        url = vk.api + '/method/groups.get?user_id=' + currentId + '&filter=admin&fields=members_count,city,counters&extended=1&v=5.52&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data) ->
            deffered.resolve(data);
        )
        .error((error) ->
            deffered.reject(error);
        );

        deffered.promise;

    getMemeberInGroup:(id, params, count = null, offset = null) ->
        deffered = $q.defer();

        if count is null then count = 1;
        if offset is null then offset = 0;
        # если участников меньше 25000 то делаем offset равным числу участников
        if count < 25000 then localOffset = Math.ceil(count / 1000) else localOffset = 25000;
        code = 'return {';
        for i in [offset...offset + localOffset] by 1000
            if i != offset + localOffset
                code = code + 'us' + i + ':API.groups.getMembers({"group_id":' + id + ',"count":"1000","offset":' + i + ',"fields":"city"}),';
            else
                code = code + 'us' + i + ':API.groups.getMembers({"group_id":' + id + ',"count":"1000","offset":' + i + ',"fields":"city"})';
        code = code + '};';


        url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&v=5.5&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data)->
            deffered.resolve(data);
        )
        .error((error)->
            deffered.reject(error);
        );

        deffered.promise;


    getGroupById: (id, params) ->
        deffered = $q.defer();

        url = vk.api + '/method/groups.getById?group_id=' + id + '&fields=members_count,city,counters,ban_info&extended=1&v=5.52&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data) ->
            deffered.resolve(data);
        )
        .error((error) ->
            deffered.reject(error);
        );

        deffered.promise;


#    todo: не используется
    getGroupName: (name, params) ->
        deffered = $q.defer();

        url = vk.api + '/method/groups.search?q=' + name + '&type=group&v=5.5&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data) ->
            deffered.resolve(data);
        )
        .error((error) ->
            deffered.reject(error);
        );

        deffered.promise;

#    todo: не используется
    getStatsGroup: (id, params) ->
        deffered = $q.defer();

        url = vk.api + '/method/stats.get?group_id=' + id + '&date_from=2013-04-23&date_to=2013-04-24&v=5.5&access_token=' + params.access_token + '&callback=JSON_CALLBACK';

        $http.jsonp(url)
        .success((data) ->
            deffered.resolve(data);
        )
        .error((error) ->
            deffered.reject(error);
        );

        deffered.promise;


