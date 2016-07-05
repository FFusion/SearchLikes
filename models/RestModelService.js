// Generated by CoffeeScript 1.7.1
'use strict';
MainModule.factory('RestModel', function($q, $http, vk) {
  var RestModel;
  RestModel = (function() {
    function RestModel() {}

    return RestModel;

  })();
  return {
    getLinkAutorization: function() {
      var url;
      url = vk.auth + '?client_id=' + vk.clientId + '&scope=friends,offline,photos,wall&redirect_uri=' + vk.redirectUri + '&display=page&response_type=token';
      return url;
    },
    _getLinkFriends: function(params, userId) {
      var id, url;
      if (userId == null) {
        userId = null;
      }
      if (userId !== null) {
        id = userId;
      } else {
        id = params.user_id;
      }
      url = vk.api + '/method/friends.get?user_id=' + id + '&v=5.8&access_token=' + params.access_token + '&order=name&fields=city,sex,online,last_seen,has_mobile,photo_50&callback=JSON_CALLBACK';
      return url;
    },
    _getLinkUser: function(id, params) {
      var url;
      if (params == null) {
        params = null;
      }
      if (params === null) {
        url = vk.api + '/method/users.get?user_id=' + id + '&v=5.8&fields=sex,bdate,city,last_seen,country,photo_200_orig,photo_100,online,contacts,status,followers_count,relation,counters,relation&callback=JSON_CALLBACK';
      } else {
        url = vk.api + '/method/users.get?user_id=' + id + '&access_token=' + params.access_token + '&v=5.8&fields=sex,bdate,city,last_seen,country,photo_200_orig,photo_100,online,contacts,status,followers_count,relation,common_count,counters,timezone&callback=JSON_CALLBACK';
      }
      return url;
    },
    _getLinkUserSimply: function(id, params) {
      var url;
      if (params == null) {
        params = null;
      }
      if (params === null) {
        url = vk.api + '/method/users.get?user_id=' + id + '&v=5.8&callback=JSON_CALLBACK';
      } else {
        url = vk.api + '/method/users.get?user_id=' + id + '&access_token=' + params.access_token + '&v=5.8&callback=JSON_CALLBACK';
      }
      return url;
    },
    _getLinkDeleteUser: function(id, params) {
      var url;
      url = vk.api + '/method/friends.delete?' + 'user_id=' + id + '&access_token=' + params.access_token + 'callback=JSON_CALLBACK';
      return url;
    },
    getParams: function(url) {
      var listParams, reg;
      listParams = {};
      reg;
      reg = url.replace(/[#&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
        return listParams[key] = value;
      });
      return listParams;
    },
    getFriends: function(params, userId) {
      var deferred, url;
      if (userId == null) {
        userId = null;
      }
      deferred = $q.defer();
      url = this._getLinkFriends(params, userId);
      $http.jsonp(url).success(function(friends) {
        return deferred.resolve(friends);
      }).error(function(error) {
        deferred.reject(error);
        return console.log(error);
      });
      return deferred.promise;
    },
    _parseTime: function(time) {
      var currentTime, finishTime, monthArray, userTime;
      currentTime = {};
      userTime = {};
      finishTime = {};
      monthArray = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
      currentTime.day = parseFloat(moment().format('Do'));
      currentTime.month = parseFloat(moment().format('MM'));
      currentTime.year = moment().format('YYYY');
      currentTime.hours = moment().format('HH');
      currentTime.minute = moment().format('mm');
      userTime.day = parseFloat(moment.unix(time).format('Do'));
      userTime.month = parseFloat(moment.unix(time).format('MM'));
      userTime.year = moment.unix(time).format('YYYY');
      userTime.hours = moment.unix(time).format('HH');
      userTime.minute = moment.unix(time).format('mm');
      if (currentTime.year !== userTime.year) {
        finishTime.year = userTime.year;
      }
      if (currentTime.month !== userTime.month) {
        finishTime.month = monthArray[userTime.month - 1];
      } else {
        finishTime.currentMonth = monthArray[currentTime.month - 1];
      }
      if (currentTime.day !== userTime.day) {
        if ((parseFloat(currentTime.day) - parseFloat(userTime.day)) === 1) {
          finishTime.day = 'вчера';
        } else {
          finishTime.day = userTime.day;
        }
      }
      if (parseFloat(currentTime.hours) !== parseFloat(userTime.hours)) {
        if ((parseFloat(currentTime.hours) - parseFloat(userTime.hours) === 1) && !finishTime.day && !finishTime.month && !finishTime.year) {
          finishTime.hours = 'час назад';
        } else {
          finishTime.hours = userTime.hours;
        }
      }
      if (parseFloat(currentTime.minute) !== parseFloat(userTime.minute)) {
        finishTime.minute = userTime.minute;
      }
      return finishTime;
    },
    _getLastEntry: function(object) {
      var time;
      time = '';
      if (object.day === 'вчера') {
        time = 'вчера в ' + object.hours + '.' + object.minute;
      }
      if (object.hours === 'час назад' && !angular.isDefined(object.day) && !angular.isDefined(object.month)) {
        time = 'час назад';
      }
      if (object.minute && !angular.isDefined(object.hours) && !angular.isDefined(object.day)) {
        time = object.minute + ' минут назад';
      }
      if (object.minute && object.hours && object.hours !== 'час назад' && !angular.isDefined(object.day) && !angular.isDefined(object.month) && !angular.isDefined(object.year)) {
        time = 'сегодня в ' + object.hours + '.' + object.minute;
      }
      if (object.minute && object.hours && object.day && object.day !== 'вчера' && !angular.isDefined(object.year) && !angular.isDefined(object.month)) {
        time = object.day + ' ' + object.currentMonth + ' в ' + object.hours + '.' + object.minute;
      }
      if (object.minute && object.hours && object.day && object.day !== 'вчера' && object.month && !angular.isDefined(object.year)) {
        time = object.day + ' ' + object.month + ' в ' + object.hours + '.' + object.minute;
      }
      if (object.minute && object.hours && object.day && object.day !== 'вчера' && object.month && object.year) {
        time = object.day + ' ' + object.month + ' ' + object.year + ' года в ' + object.hours + '.' + object.minute;
      }
      if (time === '') {
        console.log(object);
      }
      return time;
    },
    _transformObject: function(object) {
      object.forEach((function(_this) {
        return function(user) {
          var lastTime, objectTime;
          if (angular.isDefined(user.last_seen) && user.online !== 1 && !angular.isDefined(user.deactivated)) {
            lastTime = user.last_seen.time;
            objectTime = _this._parseTime(lastTime);
            return user.last_seen = _this._getLastEntry(objectTime);
          } else if (user.online === 1) {
            return user.last_seen = 'online';
          } else if (user.deactivated === 'deleted' || (user.deactivated = "banned")) {
            return user.last_seen = 'удален';
          }
        };
      })(this));
      return object;
    },
    isWorkingFriendsObject: function(object) {
      var params, temp;
      console.log(object);
      params = {};
      temp = {};
      if (object.response.items) {
        temp = object.response.items;
        params = this._transformObject(temp);
      } else {
        params = object.response[0];
      }
      return params;
    },
    filteredUsers: function(users, type) {
      var scaningUsers;
      scaningUsers = [];
      angular.forEach(users, function(user) {
        if (type === "male" && user.sex === 2 && !angular.isDefined(user.deactivated)) {
          scaningUsers.push(user);
        }
        if (type === "female" && user.sex === 1 && !angular.isDefined(user.deactivated)) {
          return scaningUsers.push(user);
        }
      });
      if (type === "all") {
        return users;
      } else {
        return scaningUsers;
      }
    },
    moreInfo: function(id, params) {
      var deffered, url, userId;
      if (params == null) {
        params = null;
      }
      deffered = $q.defer();
      userId = parseFloat(id);
      url = this._getLinkUser(userId, params);
      $http.jsonp(url).success(function(user) {
        return deffered.resolve(user);
      }).error(function(error) {
        deffered.reject(error);
        return console.log(error);
      });
      return deffered.promise;
    },
    getUserById: function(id, params) {
      var deffered, url, userId;
      if (id == null) {
        id = null;
      }
      if (params == null) {
        params = null;
      }
      deffered = $q.defer();
      userId = id !== null ? parseFloat(id) : 1;
      url = this._getLinkUserSimply(userId, params);
      $http.jsonp(url).success(function(user) {
        return deffered.resolve(user);
      }).error(function(error) {
        deffered.reject(error);
        return console.log(error);
      });
      return deffered.promise;
    },
    sendMessage: function(id, params) {
      var deffered, url;
      deffered = $q.defer();
      url = this._getLinkMessage(id, params);
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    deleteUser: function(id, params) {
      var deffered, url;
      deffered = $q.defer();
      url = this._getLinkDeleteUser(id, params);
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getWallPost: function(userId, params, count, filter) {
      var deffered, url;
      if (filter == null) {
        filter = null;
      }
      if (filter === null) {
        filter = 'owner';
      } else {
        userId = '-' + userId;
      }
      deffered = $q.defer();
      url = vk.api + '/method/wall.get?' + 'owner_id=' + userId + '&count=' + count + '&filter=' + filter + '&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getAllWallPost: function(userId, params, count, offset) {
      var deffered, url;
      if (count == null) {
        count = null;
      }
      if (offset == null) {
        offset = null;
      }
      if (count === null) {
        count = 100;
      }
      if (offset === null) {
        offset = 0;
      }
      deffered = $q.defer();
      url = vk.api + '/method/wall.get?' + 'owner_id=' + userId + '&count=' + count + '&offset=' + offset + '&filter=owner&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getLikes: function(userId, params, postId, type) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/likes.getList?' + 'owner_id=' + userId + '&item_id=' + postId + '&type=' + type + '&filter=likes&friend_only=0&count=1000&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getAllLikes: function(id, params, postId, type, count, offset) {
      var deffered, url;
      if (count == null) {
        count = null;
      }
      if (offset == null) {
        offset = null;
      }
      deffered = $q.defer();
      if (count === null) {
        count = 1000;
      }
      if (offset === null) {
        offset = 0;
      }
      url = vk.api + '/method/likes.getList?' + 'owner_id=' + id + '&item_id=' + postId + '&type=' + type + '&filter=likes&friend_only=0&count=' + count + '&offset=' + offset + '&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    friendsOnlineOrDelete: function(type, friends) {
      var friendsArray;
      if (type == null) {
        type = null;
      }
      friendsArray = [];
      if (type === 'online') {
        friends.forEach(function(friend) {
          if (friend.online === 1) {
            return friendsArray.push(friend);
          }
        });
      }
      if (type === 'delete') {
        friends.forEach(function(friend) {
          if (angular.isDefined(friend.deactivated)) {
            return friendsArray.push(friend);
          }
        });
      }
      if (type === null) {
        friends.forEach(function(friend) {
          if (!angular.isDefined(friend.deactivated)) {
            return friendsArray.push(friend);
          }
        });
      }
      return friendsArray;
    },
    getPhoto: function(userId, params, count, type) {
      var deffered, url;
      deffered = $q.defer();
      if (type === "all") {
        url = vk.api + '/method/photos.getAll?' + 'owner_id=' + userId + '&count=' + count + '&no_service_albums=1&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      } else {
        url = vk.api + '/method/photos.get?' + 'owner_id=' + userId + '&album_id=' + type + '&rev=1&count=' + count + '&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      }
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getPhotoAll: function(userId, params, count, offset) {
      var deffered, url;
      if (count == null) {
        count = null;
      }
      if (offset == null) {
        offset = null;
      }
      deffered = $q.defer();
      if (count === null) {
        count = 200;
      }
      if (offset === null) {
        offset = 0;
      }
      url = vk.api + '/method/photos.getAll?' + 'owner_id=' + userId + '&count=' + count + '&offset=' + offset + '&v=5.27&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getComment: function(userId, post, params) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/wall.getComments?' + 'owner_id=' + userId + '&post_id=' + post.id + '&extended=1&count=100&need_likes=1&v=5.28&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getWish: function(content) {
      var deffered;
      deffered = $q.defer();
      $http.post('mail.php', {
        fio: content.fio,
        email: content.email,
        wish: content.wish
      }).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getWishUser: function(id) {
      var deffered;
      deffered = $q.defer();
      $http.post('mail.php', {
        fio: id,
        email: '',
        wish: ''
      }).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getLikesExecute: function(userId, object, params, type) {
      var code, count, deffered, i, url, _i, _ref;
      deffered = $q.defer();
      count = 0;
      code = 'return {';
      for (i = _i = 0, _ref = object.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (i !== object.length - 1) {
          code = code + 'listLikes_' + object[i].id + ':API.likes.getList({"type":"' + type + '", "owner_id":' + object[i].owner_id + ',"item_id":' + object[i].id + ',"friends_only":0, "count":1000}),';
        } else {
          code = code + 'listLikes_' + object[i].id + ':API.likes.getList({"type":"' + type + '", "owner_id":' + object[i].owner_id + ',"item_id":' + object[i].id + ',"friends_only":0, "count":1000})';
        }
      }
      code = code + '};';
      url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getCommentsCount: function(userId, params, count, offset) {
      var deffered, url;
      if (count == null) {
        count = null;
      }
      if (offset == null) {
        offset = null;
      }
      deffered = $q.defer();
      if (count === null) {
        count = 1;
      }
      if (offset === null) {
        offset = 0;
      }
      url = vk.api + '/method/photos.getAllComments?owner_id=' + userId + '&count=' + count + '&offset=' + offset + '&access_token=' + params.access_token + '&v=5.5&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getPhotosById: function(photos) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/photos.getById?photos=' + photos + '&v=5.5&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getCommentsByPhoto: function(photo, params) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/photos.getComments?owner_id=' + photo.owner_id + '&photo_id=' + photo.id + '&extended=1&v=5.5&count=100&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getAllCountFriends: function(arrayFriends, params) {
      var code, deffered, i, url, _i, _ref;
      deffered = $q.defer();
      code = 'return {';
      for (i = _i = 0, _ref = arrayFriends.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (i !== arrayFriends.length - 1) {
          code = code + 'CountFr' + arrayFriends[i].id + ':API.users.get({"fields":"counters,photo_50", "user_id":' + arrayFriends[i].id + '}),';
        } else {
          code = code + 'CountFr' + arrayFriends[i].id + ':API.users.get({"fields":"counters,photo_50", "user_id":' + arrayFriends[i].id + '})';
        }
      }
      code = code + '};';
      url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getGroupCurentUserAdmin: function(currentId, params) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/groups.get?user_id=' + currentId + '&filter=admin&fields=members_count,city,counters&extended=1&v=5.52&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getMemeberInGroup: function(id, params, count, offset) {
      var code, deffered, i, localOffset, url, _i, _ref;
      if (count == null) {
        count = null;
      }
      if (offset == null) {
        offset = null;
      }
      deffered = $q.defer();
      if (count === null) {
        count = 1;
      }
      if (offset === null) {
        offset = 0;
      }
      if (count < 25000) {
        localOffset = Math.ceil(count / 1000);
      } else {
        localOffset = 25;
      }
      code = 'return {';
      for (i = _i = offset, _ref = offset + localOffset; offset <= _ref ? _i < _ref : _i > _ref; i = offset <= _ref ? ++_i : --_i) {
        if (i !== offset + localOffset) {
          code = code + 'us' + i + ':API.groups.getMembers({"group_id":' + id + ',"count":"1000","offset":' + i + ',"fields":"city,online"}),';
        } else {
          code = code + 'us' + i + ':API.groups.getMembers({"group_id":' + id + ',"count":"1000","offset":' + i + ',"fields":"city,online"})';
        }
      }
      code = code + '};';
      url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&v=5.5&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getGroupById: function(id, params) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/groups.getById?group_id=' + id + '&fields=members_count,city,counters,ban_info&extended=1&v=5.52&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getGroupName: function(name, params) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/groups.search?q=' + name + '&type=group&v=5.5&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getStatsGroup: function(id, params) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/stats.get?group_id=' + id + '&date_from=2013-04-23&date_to=2013-04-24&v=5.5&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getListUserInExcel: function(users) {
      var data, deffered;
      deffered = $q.defer();
      data = JSON.stringify(users);
      $http.post('excel.php', {
        data: data
      }).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getUsersHomeTown: function(town, city, params) {
      var deffered, url;
      if (town == null) {
        town = '';
      }
      if (city == null) {
        city = '';
      }
      deffered = $q.defer();
      url = vk.api + '/method/users.search?city=' + city + '&hometown=' + town + '&fields=city,photo_50&sort=0&count=5&v=5.5&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getTown: function(city) {
      var deffered, url;
      deffered = $q.defer();
      url = vk.api + '/method/database.getCities?country_id=1&region_id=' + city + '&hometown=' + town + '&fields=city,photo_50&sort=0&count=5&v=5.5&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    },
    getProfilePhoto: function(arrayFriends, params) {
      var code, deffered, i, url, _i, _ref;
      deffered = $q.defer();
      code = 'return {';
      for (i = _i = 0, _ref = arrayFriends.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (i !== arrayFriends.length - 1) {
          code = code + 'CountFr' + arrayFriends[i].id + ':API.photos.get({"owner_id":' + arrayFriends[i].id + ',"album_id":"profile", "rev": 1, "count":2}),';
        } else {
          code = code + 'CountFr' + arrayFriends[i].id + ':API.photos.get({"owner_id":' + arrayFriends[i].id + ',"album_id":"profile", "rev": 1, "count":2})';
        }
      }
      code = code + '};';
      url = vk.api + '/method/execute?code=' + code + '&access_token=' + params.access_token + '&callback=JSON_CALLBACK';
      $http.jsonp(url).success(function(data) {
        return deffered.resolve(data);
      }).error(function(error) {
        return deffered.reject(error);
      });
      return deffered.promise;
    }
  };
});

//# sourceMappingURL=RestModelService.map
