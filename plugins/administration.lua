do

  local bot_repo = 'https://git.io/v4Oi0'
  local NUM_MSG_MAX = 4  -- Max number of messages per TIME_CHECK seconds
  local TIME_CHECK = 4

  local function is_banned(chat_id, user_id)
    local hash = 'banned:' .. chat_id
    local banned = redis:sismember(hash, user_id)
    return banned or false
  end

  local function is_globally_banned(user_id)
    local hash = 'globanned'
    local banned = redis:sismember(hash, user_id)
    return banned or false
  end

  local function is_privileged(msg, gid, uid)
    local var = false
    if is_mod(msg, gid, uid) or uid == our_id or uid == tonumber(_config.bot_api.uid) then
      var = true
    end
    return var
  end

  local function get_sudolist(msg)
    local sudoers = 'List of sudoers:\n\n'
    for k,v in pairs(_config.sudo_users) do
      sudoers = sudoers .. '- ' .. v .. ' - ' .. k .. '\n'
    end
    reply_msg(msg.id, sudoers, ok_cb, true)
  end

  local function get_adminlist(msg, gid)
    local group = gid or msg.to.title
    if is_administrate(msg, gid) then
      if next(_config.administrators) == nil then
        reply_msg(msg.id, 'There are currently no listed administrators.', ok_cb, true)
      else
        local message = 'List of administrators:\n\n'
        for k,v in pairs(_config.administrators) do
          message = message .. '- ' .. v .. ' - ' .. k .. '\n'
        end
        reply_msg(msg.id, message, ok_cb, true)
      end
    end
  end

  local function del_adminlist(msg, gid)
    local group = gid or msg.to.title
    if is_administrate(msg, gid) then
      if next(_config.administrators) == nil then
        reply_msg(msg.id, 'There are currently no listed administrators.', ok_cb, true)
      else
        _config.administrators = {}
        save_config()
        reply_msg(msg.id, 'All administrators has been demoted.', ok_cb, true)
      end
    end
  end

  local function get_ownerlist(msg, chat_id)
    local gid = tonumber(chat_id)
    local group = msg.to.title or gid
    local data = load_data(_config.administration[gid])
    if is_administrate(msg, gid) then
      if next(data.owners) == nil then
        reply_msg(msg.id, 'There are currently no listed owners.', ok_cb, true)
      else
        local message = group .. ' owner(s):\n\n'
        for k,v in pairs(data.owners) do
          message = message .. '- ' .. v .. ' - ' .. k .. '\n'
        end
        reply_msg(msg.id, message, ok_cb, true)
      end
    end
  end

  local function del_ownerlist(msg, gid)
    local group = gid or msg.to.title
    if is_administrate(msg, gid) then
      local data = load_data(_config.administration[gid])
      if next(data.owners) == nil then
        reply_msg(msg.id, 'There are currently no listed owners.', ok_cb, true)
      else
        data.owners = {}
        save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
        reply_msg(msg.id, 'All of ' .. group .. ' owners has been demoted.', ok_cb, true)
      end
    end
  end

  local function get_modlist(msg, gid)
    local gid = tonumber(gid)
    if is_administrate(msg, gid) then
      local data = load_data(_config.administration[gid])
      if next(data.moderators) == nil then
        reply_msg(msg.id, 'There are currently no listed moderators.', ok_cb, true)
      else
        local message = 'Moderators for ' .. data.name .. ':\n\n'
        for k,v in pairs(data.moderators) do
          message = message .. '- ' .. v .. ' [' .. k .. '] \n'
        end
        reply_msg(msg.id, message, ok_cb, true)
      end
    end
  end

  local function del_modlist(msg, gid)
    if is_administrate(msg, gid) then
      local data = load_data(_config.administration[gid])
      if next(data.moderators) == nil then
        reply_msg(msg.id, 'There are currently no listed moderators.', ok_cb, true)
      else
        data.moderators = {}
        save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
        reply_msg(msg.id, 'All of ' .. data.name .. ' moderators has been demoted.', ok_cb, true)
      end
    end
  end

  local function update_members_list(extra, success, result)
    if extra.to.peer_type == 'channel' then
      chat_id = extra.to.peer_id
      member_list = result
    else
      chat_id = result.peer_id
      member_list = result.members
    end
    local gid = tonumber(chat_id)
    local data = load_data(_config.administration[gid])
    for k,v in pairsByKeys(member_list) do
      data.members[v.peer_id] = v.username or ''
    end
    save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
  end

  -- kick user
  local function kick_user(msg, chat_id, user_id)
    local gid = tonumber(chat_id)
    local uid = tonumber(user_id)
    -- check if user was kicked in the last TIME_CHECK seconds
    if not redis:get('kicked:' .. gid .. ':' .. uid) or false then
      if is_privileged(msg, gid, uid) then
        reply_msg(msg.id, uid .. ' is too privileged to be kicked.', ok_cb, true)
      else
        if msg.to.peer_type == 'channel' then
          channel_kick_user('channel#id' .. gid, 'user#id' .. uid, ok_cb, true)
        else
          chat_del_user('chat#id' .. gid, 'user#id' .. uid, ok_cb, true)
        end
      end
    end
    -- set for TIME_CHECK seconds that user have been kicked
    redis:setex('kicked:' .. gid .. ':' .. uid, TIME_CHECK, 'true')
  end

  local function invite_user(msg, gid, uid)
    local data = load_data(_config.administration[gid])
    local g_type = data.group_type
    if is_globally_banned(uid) then
      reply_msg(msg.id, 'Invitation canceled.\nID ' .. uid .. ' is globally banned.', ok_cb, true)
    elseif is_banned(gid, uid) then
      reply_msg(msg.id, 'Invitation canceled.\nID ' .. uid .. ' is banned.', ok_cb, true)
    else
      if g_type == 'channel' then
        channel_invite_user(g_type .. '#id' .. gid, 'user#id' .. uid, ok_cb, true)
      else
        chat_add_user(g_type .. '#id' .. gid, 'user#id' .. uid, ok_cb, true)
      end
    end
  end

  local function ban_user(extra, gid, uid)
    local msg = extra.msg
    local usr = extra.usr
    local data = load_data(_config.administration[gid])
    if is_privileged(msg, gid, uid) then
      reply_msg(msg.id, usr .. ' is too privileged to be banned.', ok_cb, true)
    else
      if is_banned(gid, uid) then
        reply_msg(msg.id, usr .. ' is already banned.', ok_cb, true)
      else
        local hash = 'banned:' .. gid
        redis:sadd(hash, uid)
        kick_user(msg, gid, uid)
        data.banned[uid] = usr
        save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
        reply_msg(msg.id, usr .. ' has been banned.', ok_cb, true)
      end
    end
  end

  local function global_ban_user(extra, gid, uid)
    local msg = extra.msg
    if is_privileged(msg, gid, uid) then
      reply_msg(msg.id, uid .. ' is too privileged to be globally banned.', ok_cb, true)
    elseif is_globally_banned(uid) then
      reply_msg(msg.id, extra.usr .. ' is already globally banned.', ok_cb, true)
    else
      local hash = 'globanned'
      redis:sadd(hash, uid)
      kick_user(extra.msg, gid, uid)
      _config.globally_banned[uid] = extra.usr
      save_config()
      reply_msg(extra.msg.id, extra.usr .. ' has been globally banned.', ok_cb, true)
    end
  end

  local function unban_user(extra, gid, uid)
    if is_banned(gid, uid) then
      local hash = 'banned:' .. gid
      local data = load_data(_config.administration[gid])
      redis:srem(hash, uid)
      data.banned[uid] = nil
      save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
      reply_msg(extra.msg.id, extra.usr .. ' has been unbanned.', ok_cb, true)
    else
      reply_msg(extra.msg.id, extra.usr .. ' is not banned.', ok_cb, true)
    end
  end

  local function global_unban_user(extra, user_id)
    if is_globally_banned(user_id) then
      local hash = 'globanned'
      redis:srem(hash, user_id)
      _config.globally_banned[user_id] = nil
      save_config()
      reply_msg(extra.msg.id, extra.usr .. ' has been globally unbanned.', ok_cb, true)
    else
      reply_msg(extra.msg.id, extra.usr .. ' is not globally banned.', ok_cb, true)
    end
  end

  local function whitelisting(extra, chat_id, user_id)
    local hash = 'whitelist'
    local is_whitelisted = redis:sismember(hash, user_id)
    if is_whitelisted then
      reply_msg(extra.msg.id, extra.usr .. ' is already whitelisted.', ok_cb, true)
    else
      redis:sadd(hash, user_id)
      reply_msg(extra.msg.id, extra.usr .. ' added to whitelist.', ok_cb, true)
    end
  end

  local function unwhitelisting(extra, chat_id, user_id)
    local hash = 'whitelist'
    local is_whitelisted = redis:sismember('whitelist', user_id)
    if not is_whitelisted then
      reply_msg(extra.msg.id, extra.usr .. ' is not whitelisted.', ok_cb, true)
    else
      redis:srem(hash, user_id)
      reply_msg(extra.msg.id, extra.usr .. ' removed from whitelist', ok_cb, true)
    end
  end

  local function promote(extra, chat_id, user_id)
    local gid = tonumber(chat_id)
    local uid = tonumber(user_id)
    local data = load_data(_config.administration[gid])
    if data.moderators ~= nil and data.moderators[uid] then
      reply_msg(extra.msg.id, uid .. ' is already a moderator.', ok_cb, true)
    else
      data.moderators[uid] = extra.usr
      save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
      reply_msg(extra.msg.id, extra.usr .. ' is now a moderator.', ok_cb, true)
    end
  end

  local function demote(extra, chat_id, user_id, force)
    local gid = tonumber(chat_id)
    local uid = tonumber(user_id)
    local data = load_data(_config.administration[gid])
    if not data.moderators[uid] then
      reply_msg(extra.msg.id, uid .. ' is not a moderator.', ok_cb, true)
    elseif uid == extra.msg.from.peer_id and not force then
      reply_msg(extra.msg.id, "You can't demote yourself.", ok_cb, true)
    else
      data.moderators[uid] = nil
      save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
      reply_msg(extra.msg.id, extra.usr .. ' is no longer a moderator.', ok_cb, true)
    end
  end

  local function promote_owner(extra, chat_id, user_id)
    local gid = tonumber(chat_id)
    local uid = tonumber(user_id)
    local data = load_data(_config.administration[gid])
    if data.owners[uid] then
      reply_msg(extra.msg.id, uid .. ' is already the group owner.', ok_cb, true)
    else
      data.owners[uid] = extra.usr
      save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
      reply_msg(extra.msg.id, extra.usr .. ' is now the group owner.', ok_cb, true)
    end
  end

  local function demote_owner(extra, chat_id, user_id, force)
    local gid = tonumber(chat_id)
    local uid = tonumber(user_id)
    local data = load_data(_config.administration[gid])
    if not data.owners[uid] then
      reply_msg(extra.msg.id, uid .. ' is not the group owner.', ok_cb, true)
    elseif uid == extra.msg.from.peer_id and not force then
      reply_msg(extra.msg.id, "You can't demote yourself.", ok_cb, true)
    else
      data.owners[uid] = nil
      save_data(data, 'data/' .. gid .. '/' .. gid .. '.lua')
      reply_msg(extra.msg.id, extra.usr .. ' is no longer the group owner.', ok_cb, true)
    end
  end

  local function promote_admin(extra, user_id)
    local uid = tonumber(user_id)
    if _config.administrators[uid] then
      reply_msg(extra.msg.id, extra.usr .. ' is already an administrator.', ok_cb, true)
    else
      channel_set_admin(get_receiver(extra.msg), 'user#id' .. uid, ok_cb, true)
      _config.administrators[uid] = extra.usr
      save_config()
      reply_msg(extra.msg.id, extra.usr .. ' is now an administrator.', ok_cb, true)
    end
  end

  local function demote_admin(extra, user_id, force)
    local uid = tonumber(user_id)
    if not _config.administrators[uid] then
      reply_msg(extra.msg.id, extra.usr .. ' is not an administrator.', ok_cb, true)
    elseif uid == extra.msg.from.peer_id and not force then
      reply_msg(extra.msg.id, "You can't demote yourself.", ok_cb, true)
    else
      channel_del_admin(get_receiver(extra.msg), 'user#id' .. uid, ok_cb, true)
      _config.administrators[uid] = nil
      save_config()
      reply_msg(extra.msg.id, extra.usr .. ' is no longer an administrator.', ok_cb, true)
    end
  end

  local function visudo(extra, user_id)
    local uid = tonumber(user_id)
    if _config.sudo_users[uid] then
      reply_msg(extra.msg.id, extra.usr .. ' is already a sudoer.', ok_cb, true)
    else
      _config.sudo_users[uid] = extra.usr
      save_config()
      reply_msg(extra.msg.id, extra.usr .. ' is now a sudoer.', ok_cb, true)
    end
  end

  local function desudo(extra, user_id, force)
    local uid = tonumber(user_id)
    if not _config.sudo_users[uid] then
      reply_msg(extra.msg.id, extra.usr .. ' is not a sudoer.', ok_cb, true)
    elseif uid == extra.msg.from.peer_id and not force then
      reply_msg(extra.msg.id, "You can't demote yourself.", ok_cb, true)
    else
      _config.sudo_users[uid] = nil
      save_config()
      reply_msg(extra.msg.id, extra.usr .. ' is no longer a sudoer.', ok_cb, true)
    end
  end

  local function get_redis_ban_records()
    for gid,cfg in pairs(_config.administration) do
      local data = load_data(_config.administration[gid])
      local banlist = redis:smembers('banned:' .. gid)
      if not data.banned then
        data.banned = {}
      end
      for x,uid in pairs(banlist) do
        data.banned[tonumber(uid)] = ''
      end
      save_data(data, cfg)
    end
    local globanlist = redis:smembers('globanned')
    if not _config.globally_banned then
      globally_banned = {}
    end
    for k,uid in pairs(globanlist) do
      _config.globally_banned[tonumber(uid)] = ''
    end
    save_config()
  end

    -- Returns the name of the sender
  local function get_username(msg)
    if msg.from.username then
      username = '@' .. msg.from.username
    elseif msg.from.first_name then
      username = msg.from.first_name
    else
      username = msg.from.peer_id
    end
    return username
  end

  local function create_group_data(msg, chat_id, user_id)
    local l_name = get_username(msg)
    if msg.action then
      t_name = _config.mkgroup.founder
    end
    gpdata = {
        antispam = 'ban',
        banned = {},
        founded = os.time(),
        founder = '',
        group_type = msg.to.peer_type,
        link = '',
        lock = {
          arabic = 'ok',
          bot = 'no',
          member = 'no',
          name = 'yes',
          photo = 'yes',
        },
        members = {},
        moderators = {},
        name = msg.to.title,
        owners = {[user_id] = t_name or l_name},
        public = true,
        set = {
          name = msg.to.title,
          photo = 'data/' .. chat_id .. '/' .. chat_id .. '.jpg',
        },
        sticker = 'ok',
        username = msg.to.username or '',
        welcome = {
          to = 'group',
        },
    }
    save_data(gpdata, 'data/' .. chat_id .. '/' .. chat_id .. '.lua')
  end

  -- [pro|de]mote|admin[prom|dem]|[global|un]ban|kick|[un]whitelist by reply
  local function action_by_reply(extra, success, result)
    local gid = tonumber(extra.to.peer_id)
    local uid = tonumber(result.from.peer_id)
    local usr = get_username(result)
    local cmd = extra.text
    if is_chat_msg(extra) then
      if cmd == '!kick' then
        kick_user(extra, gid, uid)
      end
      if cmd == '!visudo' or cmd == '!sudo' then
        visudo({msg=extra, usr=usr}, uid)
      end
      if cmd == '!desudo' then
        desudo({msg=extra, usr=usr}, uid)
      end
      if cmd == '!adminprom' or cmd == '!admin' then
        promote_admin({msg=extra, usr=usr}, uid)
      end
      if cmd == '!admindem' or cmd == '!deadmin' then
        demote_admin({msg=extra, usr=usr}, uid)
      end
      if cmd == '!setowner' or cmd == '!gov' then
        promote_owner({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!remowner' or cmd == '!degov' then
        demote_owner({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!promote' or cmd == '!mod' then
        promote({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!demote' or cmd == '!demod' then
        demote({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!invite' then
        invite_user(extra, gid, uid)
      end
      if cmd == '!ban' then
        ban_user({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!superban' or cmd == '!gban' or cmd == '!hammer' then
        global_ban_user({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!unban' then
        unban_user({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!superunban' or cmd == '!gunban' or cmd == '!unhammer' then
        global_unban_user({msg=extra, usr=usr}, uid)
      end
      if cmd == '!whitelist' then
        whitelisting({msg=extra, usr=usr}, gid, uid)
      end
      if cmd == '!unwhitelist' then
        unwhitelisting({msg=extra, usr=usr}, gid, uid)
      end
    end
  end

  -- [pro|de]mote|admin[prom|dem]|[global|un]ban|kick|[un]whitelist by username
  local function resolve_username_cb(extra, success, result)
    if result ~= false then
      local msg = extra.msg
      local uid = result.peer_id
      local cmd = extra.matches[1]
      if result.username then
        usr = '@' .. result.username
      else
        usr = uid
      end
      if is_chat_msg(msg) then
        gid = msg.to.peer_id
      else
        gid = extra.matches[4]
      end
      if cmd == 'kick' then
        kick_user(msg, gid, uid)
      end
      if cmd == 'invite' or cmd == 'gadd' then
        invite_user(msg, gid, uid)
      end
      if cmd == 'ban' then
        ban_user({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'superban' or cmd == 'gban' or cmd == 'hammer' then
        global_ban_user({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'unban' then
        unban_user({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'superunban' or cmd == 'gunban' or cmd == 'unhammer' then
        global_unban_user({msg=msg, usr=usr}, uid)
      end
      if cmd == 'visudo' or cmd == 'sudo' then
        visudo({msg=msg, usr=usr}, uid)
      end
      if cmd == 'desudo' then
        desudo({msg=msg, usr=usr}, uid)
      end
      if cmd == 'admin' or cmd == 'adminprom' then
        promote_admin({msg=msg, usr=usr}, uid)
      end
      if cmd == 'deadmin' or cmd == 'admindem' then
        demote_admin({msg=msg, usr=usr}, uid)
      end
      if cmd == 'setowner' or cmd == 'gov' then
        promote_owner({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'remowner' or cmd == 'degov' then
        demote_owner({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'promote' or cmd == 'mod' then
        promote({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'demote' or cmd == 'demod' then
        demote({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'whitelist' then
        whitelisting({msg=msg, usr=usr}, gid, uid)
      end
      if cmd == 'unwhitelist' then
        unwhitelisting({msg=msg, usr=usr}, gid, uid)
      end
    else
      reply_msg(extra.msg.id, '@' .. extra.matches[3] .. ' is not member of this group.', ok_cb, true)
    end
    if success == 0 then
      reply_msg(extra.msg.id, 'Failed to invite @' .. extra.matches[3] .. ' into this group.\nCheck if the username is correct.', ok_cb, true)
    end
  end

  -- trigger anti spam and anti flood
  local function trigger_anti_spam(extra, chat_id, user_id)
    local data = load_data(_config.administration[chat_id])
    if data.antispam == 'kick' then
      kick_user(extra.msg, chat_id, user_id)
      reply_msg(extra.msg.id, extra.usr .. ' is ' .. extra.stype)
    elseif data.antispam == 'ban' then
      ban_user({msg=extra.msg, usr=extra.usr}, chat_id, user_id)
      reply_msg(extra.msg.id, extra.usr .. ' is ' .. extra.stype .. '. Banned')
    end
    if not is_chat_msg(extra.msg) then
      send_msg(get_receiver(extra.msg), extra.usr .. ' is ' .. extra.stype .. '. Blocked.', ok_cb, true)
      block_user('user#id' .. user_id, ok_cb, false)
    end
    msg = nil
  end

  -- callback for invite link
  local function set_group_link_cb(extra, success, result)
    local data = load_data(extra.file)
    data.link = result
    save_data(data, extra.file)
    if extra.mute == 'revoke' then
      data.link = 'revoked'
      save_data(data, extra.file)
    elseif extra.mute ~= true then
      reply_msg(extra.msg.id, result, ok_cb, true)
    end
  end

  -- set chat|channel invite link
  local function set_group_link(extra, file, mute)
    if extra.msg.to.peer_type == 'channel' then
      export_channel_link('channel#id' .. extra.gid, set_group_link_cb, {msg=extra.msg, file=file, mute=mute})
    else
      export_chat_link('chat#id' .. extra.gid, set_group_link_cb, {msg=extra.msg, file=file, mute=mute})
    end
  end

  -- set chat|group photo
  local function set_group_photo(extra, success, result)
    local data = extra.data
    local msg = extra.msg
    if success then
      local filepath = 'data/' .. msg.to.peer_id .. '/' .. msg.to.peer_id
      print('File downloaded to:', result)
      os.rename(result, filepath .. '.jpg')
      print('File moved to:', filepath .. '.jpg')
      if msg.to.peer_type == 'channel' then
        channel_set_photo(get_receiver(msg), filepath .. '.jpg', ok_cb, false)
      else
        chat_set_photo(get_receiver(msg), filepath .. '.jpg', ok_cb, false)
      end
      data.set.photo = filepath .. '.jpg'
      save_data(data, filepath .. '.lua')
      data.lock.photo = 'yes'
      save_data(data, filepath .. '.lua')
      reply_msg(msg.id, 'Photo saved!', ok_cb, false)
    else
      print('Error downloading: ' .. msg.id)
      reply_msg(msg.id, 'Error downloading this photo, please try again.', ok_cb, false)
    end
  end

  local function load_group_photo(msg, gid)
    local g_type = msg.to.peer_type
    local dl_dir = '.telegram-cli/downloads'
    local cmd = 'load_%s_photo %s#id%s'
    local command = cmd:format(g_type, g_type, gid)
    os.execute('mv ' .. dl_dir .. ' ' .. dl_dir .. '-bak && mkdir ' .. dl_dir)
    os.execute(tgclie:format(command))
    local g_photo = scandir(dl_dir)
    if g_photo[3] and g_photo[3]:match('jpg') then
      os.rename(dl_dir .. '/' .. g_photo[3], 'data/' .. gid .. '/' .. gid .. '.jpg')
      os.execute('rm -r ' .. dl_dir .. ' && mv ' .. dl_dir .. '-bak ' .. dl_dir)
    end
  end

  local function add_group(msg, chat_id, user_id)
    local gid = tonumber(chat_id)
    local group = msg.to.title or gid
    local cfg = 'data/' .. gid .. '/' .. gid .. '.lua'
    if _config.administration[gid] then
      reply_msg(msg.id, 'I am already administrating ' .. group, ok_cb, true)
    else
      os.execute('mkdir -p data/' .. gid)
      _config.administration[gid] = cfg
      save_config()
      create_group_data(msg, gid, user_id)
      set_group_link({msg=msg, gid=gid}, cfg, true)
      if msg.to.peer_type == 'channel' then
        channel_get_users('channel#id' .. gid, update_members_list, msg)
      else
        chat_info('chat#id' .. gid, update_members_list, msg)
      end
      get_redis_ban_records()
      load_group_photo(msg, gid)
      reply_msg(msg.id, 'I am now administrating ' .. group, ok_cb, true)
    end
  end

  local function remove_group(msg, chat_id)
    local gid = tonumber(chat_id)
    local group = msg.to.title or gid
    if is_administrate(msg, gid) then
      _config.administration[gid] = nil
      save_config()
      os.execute('rm -r data/' .. gid)
      reply_msg(msg.id, 'I am no longer administrating ' .. group, ok_cb, true)
    end
  end

  local function get_config(msg, gid)
    if gid then
      local cfg_cp = '/tmp/' .. gid .. '.lua'
      os.execute('cp data/' .. gid .. '/' .. gid .. '.lua ' .. cfg_cp)
      send_document(get_receiver(msg), cfg_cp, rmtmp_cb, {file_path=cfg_cp})
    else
      local cfg_cp = '/tmp/config.lua'
      os.execute('cp data/config.lua ' .. cfg_cp)
      send_document('user#id' .. msg.from.peer_id, cfg_cp, rmtmp_cb, {file_path=cfg_cp})
    end
  end

  -- Create a Group chat
  local function create_group(msg, title, g_type)
    if not _config.mkgroup then
      _config.mkgroup = {founded = '', founder = '', title = '', gtype = '', uid = ''}
      save_config()
    end
    local rightnow = msg.date
    local last_time = tonumber(_config.mkgroup.founded) or 0
    if os.difftime(rightnow, last_time) > 3600 then
      local uname = msg.from.username or msg.from.first_name
      _config.mkgroup = {founded = rightnow, founder = uname, title = title, gtype = g_type, uid = msg.from.peer_id}
      save_config()
      create_group_chat(msg.from.print_name, title, ok_cb, false)
      reply_msg(msg.id, 'Group ' .. title .. ' has been created.', ok_cb, true)
    else
      reply_msg(msg.id, 'I limit myself to create a group per hours.\n'
           .. 'Please try again in next one hour.', ok_cb, true)
    end
  end

  -- Global broadcasting
  local function send_broadcast(msg, bc_msg)
    local data = _config.administration
    for gid,v in pairs(data) do
      local g_type = load_data(data[gid]).group_type
      if g_type == 'chat' then
        bc_rcvr = '-' .. gid
      elseif g_type == 'channel' then
        bc_rcvr = '-100' .. gid
      end
      --send_large_msg(g_type .. '#id' .. gid, bc_msg)
      bot_sendMessage(bc_rcvr, bc_msg, false, nil, nil)
    end
  end



  local function pre_process(msg)

    local uid = msg.from.peer_id
    local gid = msg.to.peer_id
    local receiver = get_receiver(msg)

    if msg.text then
      -- If sender is sudo then re-enable the channel
      if msg.text == '!channel enable' and is_sudo(uid) then
        _config.disabled_channels[receiver] = false
        save_config()
      end
      if _config.disabled_channels[receiver] == true then
        msg.text = ''
      end

      -- Anti arabic
      if msg.text:match('([\216-\219][\128-\191])') and _config.administration[gid] then
        if uid > 0 and not is_mod(msg, gid, uid) then
          local data = load_data(_config.administration[gid])
          local arabic_hash = 'mer_arabic:' .. gid
          local is_arabic_offender = redis:sismember(arabic_hash, uid)
          if data.lock.arabic == 'warn' then
            if is_arabic_offender then
              kick_user(msg, gid, uid)
              redis:srem(arabic_hash, uid)
            end
            if not is_arabic_offender then
              redis:sadd(arabic_hash, uid)
              reply_msg(msg.id, 'Please do not post in arabic.\n'
                   .. 'Obey the rules or you will be kicked.', ok_cb, true)
            end
          end
          if data.lock.arabic == 'kick' then
            kick_user(msg, gid, uid)
            reply_msg(msg.id, 'Arabic is not allowed here!', ok_cb, true)
          end
        end
      end

      -- Anti spam
      if msg.from.peer_type == 'user' and not is_mod(msg, gid, uid) then
        local _nl, ctrl_chars = msg.text:gsub('%c', '')
        -- If string length more than 2048 or control characters is more than 50
        if string.len(msg.text) > 2048 or ctrl_chars > 50 then
          local _c, chars = msg.text:gsub('%a', '')
          local _nc, non_chars = msg.text:gsub('%A', '')
          -- If sums of non characters is bigger than characters
          if non_chars > chars then
            local username = get_username(msg)
            trigger_anti_spam({msg=msg, stype='spamming', usr=username}, gid, uid)
          end
        end
      end
    end

    -- If banned user is talking
    if is_chat_msg(msg) then
      if is_globally_banned(uid) then
        print('>>> SuperBanned user talking!')
        kick_user(msg, gid, uid)
        msg.text = ''
      elseif is_banned(gid, uid) then
        print('>>> Banned user talking!')
        kick_user(msg, gid, uid)
        msg.text = ''
      end
    end

    -- If whitelist enabled
    -- Allow all sudo users even if whitelist is allowed
    if redis:get('whitelist:enabled') and not is_sudo(uid) then
      print('>>> Whitelist enabled and not sudo')
      -- Check if user or chat is whitelisted
      local allowed = redis:sismember('whitelist', uid) or false
      if not allowed then
        print('>>> User ' .. uid .. ' not whitelisted')
        if is_chat_msg(msg) then
          allowed = redis:sismember('whitelist', gid) or false
          if not allowed then
            print('>>> Chat ' .. gid .. ' not whitelisted')
          else
            print('>>> Chat ' .. gid .. ' whitelisted :)')
          end
        end
      else
        print('>>> User ' .. uid .. ' allowed :)')
      end
      if not allowed then
        msg.text = ''
      end
    end

    if msg.action then
      if _config.administration[gid] then
        local data = load_data(_config.administration[gid])
        -- If user enter the group, either by invited or by clicking invite link
        if msg.action.type == 'chat_add_user' or msg.action.type == 'chat_add_user_link' then
          if msg.action.link_issuer then
            userid = uid
            new_member = (msg.from.first_name or '') .. ' ' .. (msg.from.last_name or '')
            greet_uname = msg.from.username or ''
          else
            userid = msg.action.user.peer_id
            new_member = (msg.action.user.first_name or '') .. ' ' .. (msg.action.user.last_name or '')
            greet_uname = msg.action.user.username or ''
          end
          -- Kick if newcomer is a banned user
          if is_globally_banned(userid) or is_banned(gid, userid) then
            kick_user(msg, gid, userid)
          end
          -- When group locked from add member or bot, kicked newly added user if the inviter is not bot or sudoer
          if uid > 0 and not is_mod(msg, gid, uid) then
            if data.lock.member == 'yes' then
              kick_user(msg, gid, userid)
            end
            -- Detecting API bot the hackish way.
            -- Regular user ended with 'bot' in their username will be kicked too.
            if data.lock.bot == 'yes' and greet_uname:match('bot$') then
              kick_user(msg, gid, userid)
            end
          end
          -- Welcome message settings
          if data.welcome.to == 'group' or data.welcome.to == 'pm' then
            -- Do not greet (globally) banned users.
            if is_globally_banned(userid) or is_banned(gid, userid) then
              return nil
            end
            -- Do not greet when group members are locked
            if data.lock.member == 'yes' then
              return nil
            end
            -- Do not greet api bot
            if greet_uname:match('bot$') then
              return nil
            end
            local group_about = ''
            local group_rules = ''
            if greet_uname:match('^%g+$') then
              greet_uname = '@' .. greet_uname .. ' AKA '
            else
              greet_uname = ''
            end
            if data.description then
              group_about = '\n<b>Description</b>:\n' .. data.description .. '\n'
            end
            if data.rules then
              group_rules = '\n<b>Rules</b>:\n' .. data.rules .. '\n'
            end
            -- Which welcome message to be send
            if data.welcome.msg then
              welcomes = data.welcome.msg .. '\n'
            -- If no custom welcome message defined, use this default
            else
              welcomes = 'Welcome ' .. greet_uname .. '<b>' .. new_member .. '</b> <code>[' .. userid .. ']</code>\nYou are in group <b>' .. msg.to.title .. '</b>\n'
            end
            if data.welcome.to == 'group' then
              receiver_api = get_receiver_api(msg)
            elseif data.welcome.to == 'private' then
              receiver_api = 'user#id' .. userid
            end
            bot_sendMessage(get_receiver_api(msg), welcomes .. group_about .. group_rules .. '\n', false, msg.id, 'html')
          end
          -- Update group's members table
          if msg.to.peer_type == 'channel' then
            channel_get_users('channel#id' .. gid, update_members_list, msg)
          else
            chat_info('chat#id' .. gid, update_members_list, msg)
          end
        end

        -- If group photo is deleted
        if msg.action.type == 'chat_delete_photo' then
          if data.lock.photo == 'yes' then
            chat_set_photo (receiver, data.set.photo, ok_cb, false)
          elseif data.lock.photo == 'no' then
            return nil
          end
        end

        -- If group photo is changed
        if msg.action.type == 'chat_change_photo' and uid ~= 0 then
          if data.lock.photo == 'yes' then
            chat_set_photo (receiver, data.set.photo, ok_cb, false)
          elseif data.lock.photo == 'no' then
            return nil
          end
        end

        -- If group name is renamed
        if msg.action.type == 'chat_rename' then
          if data.lock.name == 'yes' then
            if data.set.name ~= tostring(msg.to.print_name) then
              rename_chat(receiver, data.set.name, ok_cb, false)
            end
          end
          if data.lock.name == 'no' then
            return nil
          end
        end

        -- If user leave, update group's members table
        if msg.action.type == 'chat_del_user' then
          if msg.to.peer_type == 'channel' then
            channel_get_users('channel#id' .. gid, update_members_list, msg)
          else
            chat_info('chat#id' .. gid, update_members_list, msg)
          end
          if is_mod(msg, gid, uid) then
            demote({msg=msg, usr=get_username(msg)}, gid, uid, 'true')
          end
          --return 'Bye ' .. new_member .. '!'
        end
      end

      -- Autoleave. Don't let users add bot to their group without permission
      if msg.action.type == 'chat_add_user' and not is_sudo(uid) then
        if _config.autoleave == true and not _config.administration[gid] then
          if msg.to.peer_type == 'channel' then
            channel_leave(receiver, ok_cb, false)
          else
            chat_del_user(receiver, 'user#id' .. our_id, ok_cb, true)
          end
        end
      end

      -- Add newly created group to be administrate
      if msg.action.type == 'chat_created' then
        local title = _config.mkgroup.title
        local founder = _config.mkgroup.uid
        local g_type = _config.mkgroup.gtype
        if g_type == 'channel' then
          chat_upgrade('chat#id' .. gid, ok_cb, false)
        elseif g_type == 'realm' then
          local cfg = 'data/' .. gid .. '/' .. gid .. '.lua'
          _config.realm = {[gid] = cfg, rgid = gid, rname = title}
          save_config()
        end
        add_group(msg, gid, founder)
      end

      -- Promote supergroup founder to be the group admin
      if msg.action.type == 'migrated_from' then
        local founder = _config.mkgroup.uid
        channel_set_admin(get_receiver(msg), 'user#id' .. founder, ok_cb, true)
      end
    end

    -- Anti flood
    local post_count = 'floodc:' .. uid .. ':' .. gid
    redis:incr(post_count)
    if msg.from.peer_type == 'user' and not is_mod(msg, gid, uid) then
      local post_count = 'user:' .. uid .. ':floodc'
      local msgs = tonumber(redis:get(post_count) or 0)
      if msgs > NUM_MSG_MAX then
        local username = get_username(msg)
        trigger_anti_spam({msg=msg, stype='flooding', usr=username}, gid, uid)
      end
      redis:setex(post_count, TIME_CHECK, msgs+1)
    end

    if msg.media and _config.administration[gid] then
      local data = load_data(_config.administration[gid])
      if not msg.text then
        msg.text = '[' .. msg.media.type .. ']'
      end
      -- Bot is waiting user to upload a new group photo
      if is_mod(msg, gid, uid) and msg.media.type == 'photo' then
        if data.set.photo == 'waiting' then
          load_photo(msg.id, set_group_photo, {msg=msg, data=data})
        end
      end
      -- If user is sending sticker
      if msg.media.caption == 'sticker.webp' then
        local sticker_hash = 'mer_sticker:' .. gid .. ':' .. uid
        local is_sticker_offender = redis:get(sticker_hash)
        if data.sticker == 'warn' then
          if is_sticker_offender then
            kick_user(msg, gid, uid)
            redis:del(sticker_hash)
          end
          if not is_sticker_offender then
            redis:set(sticker_hash, true)
            reply_msg(msg.id, 'DO NOT send sticker into this group!\n'
                 .. 'This is a WARNING, next time you will be kicked!', ok_cb, true)
          end
        end
        if data.sticker == 'kick' then
          kick_user(msg, gid, uid)
          reply_msg(msg.id, 'DO NOT send sticker into this group!', ok_cb, true)
        end
      end
    end
    -- No further checks
    return msg
  end



  local function run(msg, matches)

    local gid = msg.to.peer_id
    local uid = msg.from.peer_id
    local chat_db = 'data/' .. gid .. '/' .. gid .. '.lua'
    local receiver = get_receiver(msg)

    if is_chat_msg(msg) then -- if in a chat group
      if is_sudo(uid) then
        -- Enabled or disable bot in a group
        if matches[1] == 'channel' then
          if matches[2] == 'enable' then
            if _config.disabled_channels[receiver] == nil then
              reply_msg(msg.id, 'Channel is not disabled', ok_cb, true)
            end
            _config.disabled_channels[receiver] = false
            save_config()
            reply_msg(msg.id, 'Channel re-enabled', ok_cb, true)
          end
          if matches[2] == 'disable' then
            _config.disabled_channels[receiver] = true
            save_config()
            reply_msg(msg.id, 'Channel disabled.', ok_cb, true)
          end
        end
        -- Add a group to be moderated. Note, this will automatically generate invite link.
        if matches[1] == 'addgroup' or matches[1] == 'gadd' then
          add_group(msg, gid, uid)
          resolve_username(_config.bot_api.uname, resolve_username_cb, {msg=msg, matches=matches})
        end

        -- Automatically leaving from unadministrated group
        if matches[1] == 'autoleave' then
          if matches[2] == 'enable' then
            _config.autoleave = true
            if not _config.autoleave then
              _config.autoleave = true
            end
            if _config.autoleave == true then
              reply_msg(msg.id, 'Autoleave is not disabled.', ok_cb, true)
            end
            save_config()
            reply_msg(msg.id, 'Autoleave re-enabled.', ok_cb, true)
          end
          if matches[2] == 'disable' then
            if not _config.autoleave then
              _config.autoleave = false
            end
            _config.autoleave = false
            save_config()
            reply_msg(msg.id, 'Autoleave disabled.', ok_cb, true)
          end
        end

        -- Remove group from administration
        if matches[1] == 'remgroup' or matches[1] == 'grem' or matches[1] == 'gremove' then
          remove_group(msg, gid)
        end

        -- Promote a user to sudoer by {id|username|name|reply}
        if matches[1] == 'visudo' or matches[1] == 'sudo' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            visudo({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- Demote a user from sudoer by {id|username|name|reply}
        if matches[1] == 'desudo' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            desudo({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- List of sudoers
        if matches[1] == 'sudolist' then
          get_sudolist(msg)
        end

        -- Promote user to be an admin by {id|username|name|reply}
        if matches[1] == 'adminprom' or matches[1] == 'admin' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            promote_admin({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- Demote user from admin by {id|username|name|reply}
        if matches[1] == 'admindem' or matches[1] == 'deadmin' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            demote_admin({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- Demote all administrators
        if matches[1] == 'clear' and matches[2] == 'admins' then
          del_adminlist(msg, gid)
        end

        -- Download 'data/config.lua'
        if msg.text == '!getconfig' then
          get_config(msg)
        end

        -- Create the realm
        if matches[2] == 'realm' then
          if not _config.realm then
            _config.realm = {}
            save_config()
          end
          if _config.realm[gid] then
            reply_msg(msg.id, 'Realm is already set.\nIf you want to replace it:\n'
                 .. '(1) !removerealm to delete the old realm\n'
                 .. '(2) !addrealm to add an existing group ass a realm, or\n'
                 .. '(3) !mkrealm to create and set new realm.', ok_cb, true)
          else
            if matches[1] == 'mk' and matches[3] then
              n_realm = matches[3]
              create_group(msg, matches[3], 'realm')
            elseif matches[1] == 'add' then
              n_realm = msg.to.title
              local cfg = 'data/' .. gid .. '/' .. gid .. '.lua'
              _config.realm = {[gid] = cfg, rgid = gid, rname = n_realm}
              save_config()
            end
            local bc_msg = '<b>' .. n_realm .. '</b> is now our new realm.\n'
                 .. 'Administrators are welcome to join in by issuing:\n<code>!joinrealm</code>'
            send_broadcast(msg, bc_msg)
          end
        end

        -- Delete the realm
        if matches[1] == 'removerealm' then
          local r_name = _config.realm.rname
          if _config.realm[gid] then
            _config.realm = {}
            save_config()
            send_broadcast(msg, 'The <b>' .. r_name .. '</b> realm has been deleted.')
          else
            reply_msg(msg.id, 'We have no realm at the moment.', ok_cb, true)
          end
        end

        -- Global broadcasting
        if matches[1] == 'broadcast' then
          send_broadcast(msg, matches[2])
        end
      end

      if is_admin(uid) then

        -- Create a Supergroup
        if matches[1] == 'mksupergroup' and matches[2] then
          create_group(msg, matches[2], 'channel')
        end

        -- Create a (normal) Group
        if matches[1] == 'mkgroup' and matches[2] then
          create_group(msg, matches[2], 'chat')
        end

        -- Set owner of a group
        if matches[1] == 'setowner' or matches[1] == 'gov' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            promote_owner({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- Remove owner of a group
        if matches[1] == 'remowner' or matches[1] == 'degov' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            demote_owner({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- Lis of administrators
        if matches[1] == 'adminlist' then
          get_adminlist(msg, gid)
        end

        -- List of owners
        if matches[1] == 'ownerlist' then
          get_ownerlist(msg, gid)
        end

        -- Demote all owners
        if matches[1] == 'clear' and matches[2] == 'owners' then
          del_ownerlist(msg, gid)
        end

        -- Globally ban user by {id|username|name|reply}
        if matches[1] == 'superban' or matches[1] == 'gban' or matches[1] == 'hammer' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            global_ban_user({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- Globally lift ban from user by {id|username|name|reply}
        if matches[1] == 'superunban' or matches[1] == 'gunban' or matches[1] == 'unhammer' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            global_unban_user({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- Enable whitelist
        if matches[1] == 'whitelist' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == 'enable' then
            redis:set('whitelist:enabled', true)
            reply_msg(msg.id, 'Enabled whitelist', ok_cb, true)
          elseif matches[2] == 'disable' then
            redis:del('whitelist:enabled')
            reply_msg(msg.id, 'Disabled whitelist', ok_cb, true)
          elseif matches[2] == 'clear' then
            local hash =  'whitelist'
            redis:del(hash)
            return "Whitelist cleared."
          elseif matches[2] == 'chat' then
            redis:sadd('whitelist', gid)
            reply_msg(msg.id, 'Chat ' .. gid .. ' whitelisted', ok_cb, true)
          end
        end

        -- Remove user from whitelist by {id|username|name|reply}
        if matches[1] == 'unwhitelist' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == 'chat' then
            redis:srem('whitelist', gid)
            reply_msg(msg.id, 'Chat ' .. gid .. ' removed from whitelist', ok_cb, true)
          end
        end

        -- List of group's moderators
        if matches[1] == 'modlist' and matches[2] and matches[2]:match('^%d+$') then
          get_modlist(msg, matches[2])
        end

        -- Broadcasting
        if matches[1] == 'bc' then
          local gid = tonumber(matches[2])
          local data = load_data(_config.administration[gid])
          local g_type = data.group_type
          send_large_msg(g_type .. '#id' .. gid, matches[3])
        end

        -- Join realm
        if matches[1] == 'joinrealm' then
          local realm_id = _config.realm.rgid
          if realm_id then
            invite_user(msg, realm_id, uid)
          else
            reply_msg(msg.id, 'No Realm at the moment', ok_cb, true)
          end
        end

      end

      if not _config.administration[gid] then return end

      local data = load_data(_config.administration[gid])

      if is_owner(msg, gid, uid) then
        if matches[1] == 'setprivate' then
          data.public = false
          save_data(data, chat_db)
          reply_msg(msg.id, 'This group is now private, will hide its invite link and no longer listed in !groups.', ok_cb, true)
        end

        if matches[1] == 'setpublic' then
          data.public = true
          save_data(data, chat_db)
          reply_msg(msg.id, 'This group is now public, will show its invite link and listed in !groups.', ok_cb, true)
        end

        -- Anti spam and flood settings
        if matches[1] == 'antispam' then
          if matches[2] == 'kick' then
            if data.antispam ~= 'kick' then
              data.antispam = 'kick'
              save_data(data, chat_db)
            end
              reply_msg(msg.id, 'Anti spam protection already enabled.\n'
                   .. 'Offender will be kicked.', ok_cb, true)
            end
          if matches[2] == 'ban' then
            if data.antispam ~= 'ban' then
              data.antispam = 'ban'
              save_data(data, chat_db)
            end
              reply_msg(msg.id, 'Anti spam protection already enabled.\n'
                   .. 'Offender will be banned.', ok_cb, true)
            end
          if matches[2] == 'disable' then
            if data.antispam == 'no' then
              reply_msg(msg.id, 'Anti spam protection is not enabled.', ok_cb, true)
            else
              data.antispam = 'no'
              save_data(data, chat_db)
              reply_msg(msg.id, 'Anti spam protection has been disabled.', ok_cb, true)
            end
          end
        end

        -- Allow user by {is|name|username|reply} to use the bot when whitelist is enabled.
        if matches[1] == 'whitelist' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3] and matches[3]:match('^%d+$') then
            whitelisting({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- Remove users permission by {is|name|username|reply} to use the bot when whitelist is enabled.
        if matches[1] == 'unwhitelist' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            unwhitelisting({msg=msg, usr=matches[3]}, matches[3])
          end
        end

        -- Invite link. Users could join the group by clicking this link.
        if matches[1] == 'setlink' or matches[1] == 'link set' then
           -- manually insert invite link
          if matches[2] then
            data.link = matches[2]
            save_data(data, chat_db)
            reply_msg(msg.id, data.link, ok_cb, true)
           -- generate invite link
          else
            set_group_link({msg=msg, gid=gid}, chat_db)
          end
        end

        -- Revoke group's invite link to make the group private
        if matches[1] == 'link revoke' then
          if data.link == '' then
            reply_msg(msg.id, "This group doesn't have invite link", ok_cb, true)
          else
            set_group_link({msg=msg, gid=gid}, chat_db, 'revoke')
            reply_msg(msg.id, 'Invite link has been revoked', ok_cb, true)
          end
        end

        -- Set group's name/title
        if matches[1] == 'setname' then
          data.name = matches[2]
          save_data(data, chat_db)
          if msg.to.peer_type == 'channel' then
            rename_channel(receiver, data.name, ok_cb, true)
          else
            rename_chat(receiver, data.name, ok_cb, true)
          end
        end

        -- Set group's photo
        if matches[1] == 'setphoto' then
          data.set.photo = 'waiting'
          save_data(data, chat_db)
          reply_msg(msg.id, 'Please send me new group photo now', ok_cb, true)
        end

        -- Sticker settings
        if matches[1] == 'sticker' then
          if matches[2] == 'warn' then
            if data.sticker ~= 'warn' then
              data.sticker = 'warn'
              save_data(data, chat_db)
            end
            reply_msg(msg.id, 'Stickers already prohibited.\n'
                 .. 'Sender will be warned first, then kicked for second violation.', ok_cb, true)
          end
          if matches[2] == 'kick' then
            if data.sticker ~= 'kick' then
              data.sticker = 'kick'
              save_data(data, chat_db)
            end
            reply_msg(msg.id, 'Stickers already prohibited.\n'
                 .. 'Sender will be kicked!', ok_cb, true)
          end
          if matches[2] == 'ok' then
            if data.sticker == 'ok' then
              reply_msg(msg.id, 'Sticker restriction is not enabled.', ok_cb, true)
            else
              data.sticker = 'ok'
              save_data(data, chat_db)
              for k,sticker_hash in pairs(redis:keys('mer_sticker:' .. gid .. ':*')) do
                redis:del(sticker_hash)
              end
              reply_msg(msg.id, 'Sticker restriction has been disabled.\n'
                   .. 'Previous infringements record has been cleared.', ok_cb, true)
            end
          end
        end

        -- Arabic settings
        if matches[1] == 'arabic' then
          if matches[2] == 'warn' then
            if data.lock.arabic ~= 'warn' then
              data.lock.arabic = 'warn'
              save_data(data, chat_db)
            end
            reply_msg(msg.id, 'This group does not allow Arabic script.\n'
                 .. 'Users will be warned first, then kicked for second infringements.', ok_cb, true)
          end
          if matches[2] == 'kick' then
            if data.lock.arabic ~= 'kick' then
              data.lock.arabic = 'kick'
              save_data(data, chat_db)
            end
            reply_msg(msg.id, 'Users will now be removed automatically for posting Arabic script.', ok_cb, true)
          end
          if matches[2] == 'ok' then
            if data.lock.arabic == 'ok' then
              reply_msg(msg.id, 'Arabic posting restriction is not enabled.', ok_cb, true)
            else
              data.lock.arabic = 'ok'
              save_data(data, chat_db)
              redis:del('mer_arabic')
--              for k,arabic_hash in pairs(redis:keys('mer_arabic:' .. gid .. ':*')) do
--                redis:del(arabic_hash)
--              end
              reply_msg(msg.id, 'Users will no longer be removed for posting Arabic script.', ok_cb, true)
            end
          end
        end

        -- Set custom welcome message
        if matches[1] == 'setwelcome' and matches[2] then
          data.welcome.msg = matches[2]
          save_data(data, chat_db)
          reply_msg(msg.id, 'Set group welcome message to:\n' .. matches[2], ok_cb, true)
        end

        -- Reset custom welcome message
        if matches[1] == 'resetwelcome' then
          data.welcome.msg = nil
          save_data(data, chat_db)
          reply_msg(msg.id, 'Welcome message has been reset.', ok_cb, true)
        end

        -- Welcome message settings
        if matches[1] == 'welcome' then
          if matches[2] == 'group' and data.welcome.to ~= 'group' then
            data.welcome.to = 'group'
            save_data(data, chat_db)
            reply_msg(msg.id, 'Welcome service already enabled.\n'
                 .. 'Welcome message will shown in group.', ok_cb, true)
          end
          if matches[2] == 'pm' and data.welcome.to ~= 'private' then
            data.welcome.to = 'private'
            save_data(data, chat_db)
            reply_msg(msg.id, 'Welcome service already enabled.\n'
                 .. 'Welcome message will send as private message to new member.', ok_cb, true)
          end
          if matches[2] == 'disable' then
            if data.welcome.to == 'no' then
              reply_msg(msg.id, 'Welcome service is not enabled.', ok_cb, true)
            else
              data.welcome.to = 'no'
              save_data(data, chat_db)
              reply_msg(msg.id, 'Welcome service has been disabled.', ok_cb, true)
            end
          end
        end

        -- Set group's description
        if matches[1] == 'setabout' and matches[2] then
          data.description = matches[2]
          save_data(data, chat_db)
          reply_msg(msg.id, 'Set group description to:\n' .. matches[2], ok_cb, true)
        end

        -- Set group's rules
        if matches[1] == 'setrules' and matches[2] then
          data.rules = matches[2]
          save_data(data, chat_db)
          reply_msg(msg.id, 'Set group rules to:\n' .. matches[2], ok_cb, true)
        end

        if matches[1] == 'group' or matches[1] == 'gp' then
          -- Lock {bot|name|member|photo|sticker}
          if matches[2] == 'lock' then
            if matches[3] == 'bot' then
              if data.lock.bot == 'yes' then
                reply_msg(msg.id, 'Group is already locked from bots.', ok_cb, true)
              else
                data.lock.bot = 'yes'
                save_data(data, chat_db)
                reply_msg(msg.id, 'Group is locked from bots.', ok_cb, true)
              end
            end
            if matches[3] == 'name' then
              if data.lock.name == 'yes' then
                reply_msg(msg.id, 'Group name is already locked', ok_cb, true)
              else
                data.lock.name = 'yes'
                save_data(data, chat_db)
                data.set.name = msg.to.title
                save_data(data, chat_db)
                reply_msg(msg.id, 'Group name has been locked', ok_cb, true)
              end
            end
            if matches[3] == 'member' then
              if data.lock.member == 'yes' then
                reply_msg(msg.id, 'Group members are already locked', ok_cb, true)
              else
                data.lock.member = 'yes'
                save_data(data, chat_db)
              end
              reply_msg(msg.id, 'Group members has been locked', ok_cb, true)
            end
            if matches[3] == 'photo' then
              if data.lock.photo == 'yes' then
                reply_msg(msg.id, 'Group photo is already locked', ok_cb, true)
              else
                data.set.photo = 'waiting'
                save_data(data, chat_db)
              end
              reply_msg(msg.id, 'Please send me the group photo now', ok_cb, true)
            end
          end
          -- Unlock {bot|name|member|photo|sticker}
          if matches[2] == 'unlock' then
            if matches[3] == 'bot' then
              if data.lock.bot == 'no' then
                reply_msg(msg.id, 'Bots are allowed to enter group.', ok_cb, true)
              else
                data.lock.bot = 'no'
                save_data(data, chat_db)
                reply_msg(msg.id, 'Group is open for bots.', ok_cb, true)
              end
            end
            if matches[3] == 'name' then
              if data.lock.name == 'no' then
                reply_msg(msg.id, 'Group name is already unlocked', ok_cb, true)
              else
                data.lock.name = 'no'
                save_data(data, chat_db)
                reply_msg(msg.id, 'Group name has been unlocked', ok_cb, true)
              end
            end
            if matches[3] == 'member' then
              if data.lock.member == 'no' then
                reply_msg(msg.id, 'Group members are not locked', ok_cb, true)
              else
                data.lock.member = 'no'
                save_data(data, chat_db)
                reply_msg(msg.id, 'Group members has been unlocked', ok_cb, true)
              end
            end
            if matches[3] == 'photo' then
              if data.lock.photo == 'no' then
                reply_msg(msg.id, 'Group photo is not locked', ok_cb, true)
              else
                data.lock.photo = 'no'
                save_data(data, chat_db)
                reply_msg(msg.id, 'Group photo has been unlocked', ok_cb, true)
              end
            end
          end
        end

        -- List of globally banned users
        if matches[1] == 'superbanlist' or matches[1] == 'gbanlist' or matches[1] == 'hammerlist' then
          local hash = 'globanned'
          local list = redis:smembers(hash)
          local gbanlist = ''
          for k,v in pairs(list) do
            gbanlist = gbanlist .. k .. " - " .. v .. "\n"
          end
          if gbanlist == '' then
            gbanlist = 'There are currently no globally banned users.'
          else
            gbanlist = 'Globally banned users list:\n\n' .. gbanlist
          end
          return gbanlist
        end

        -- Promote group moderator
        if matches[1] == 'promote' or matches[1] == 'mod' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            promote({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- Demote group moderator
        if matches[1] == 'demote' or matches[1] == 'demod' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            demote({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- Demote all moderators
        if matches[1] == 'clear' and matches[2] == 'mods' then
          del_modlist(msg, gid)
        end

        -- Download group configuration file.
        if matches[1] == 'getconfig' and matches[2]:match('^%d+$') then
          get_config(msg, matches[2])
        end
      end

      if is_mod(msg, gid, uid) then
        -- Print group settings
        if matches[1] == 'group' and matches[2] == 'settings' then
          local text = 'Settings for *' .. msg.to.title .. '*\n'
                 .. '*-* Arabic message = `' .. data.lock.arabic .. '`\n'
                 .. '*-* Lock group from bot = `' .. data.lock.bot .. '`\n'
                 .. '*-* Lock group name = `' .. data.lock.name .. '`\n'
                 .. '*-* Lock group photo = `' .. data.lock.photo .. '`\n'
                 .. '*-* Lock group member = `' .. data.lock.member .. '`\n'
                 .. '*-* Spam protection = `' .. data.antispam .. '`\n'
                 .. '*-* Sticker policy = `' .. data.sticker .. '`\n'
                 .. '*-* Welcome message = `' .. data.welcome.to .. '`\n'
          bot_sendMessage(get_receiver_api(msg), text, false, msg.id, 'markdown')
        end

        -- Invite user by {id|username|name|reply}
        if matches[1] == 'invite' then
          local noinvite = 'Invite feature has been disabled to prevent bot '
              .. 'reported as spam.\nPlease use the invite link.'

          if _config.no_invite and not is_sudo(uid) and matches[2] ~= 'enable' then
            reply_msg(msg.id, noinvite, ok_cb, true)
            return
          end
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[2] == 'enable' then
            _config.no_invite = false
            save_config()
            reply_msg(msg.id, 'Invite feature has been enabled', ok_cb, true)
          elseif matches[2] == 'disable' then
            _config.no_invite = true
            save_config()
            reply_msg(msg.id, noinvite, ok_cb, true)
          elseif matches[3]:match('%d+$') then
            invite_user(msg, gid, matches[3])
          else
            -- Invite user by their print name. Unreliable.
            if msg.to.peer_type == 'channel' then
              channel_invite_user(receiver, matches[3]:gsub(' ', '_'), ok_cb, false)
            else
              chat_add_user(receiver, matches[3]:gsub(' ', '_'), ok_cb, false)
            end
          end
        end

        -- Kick user by {id|username|name|reply}
        if matches[1] == 'kick' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            kick_user(msg, gid, matches[3])
          end
        end

        -- Kick user by {id|username|name|reply} and re-kick if rejoin
        if matches[1] == 'ban' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3] and matches[3]:match('^%d+$') then
            ban_user({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- Lift ban by {id|username|name|reply}
        if matches[1] == 'unban' then
          if msg.reply_id then
            get_message(msg.reply_id, action_by_reply, msg)
          elseif matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            unban_user({msg=msg, usr=matches[3]}, gid, matches[3])
          end
        end

        -- List of group's banned users
        if matches[1] == 'banlist' then
          local hash = 'banned:' .. gid
          local list = redis:smembers(hash)
          local banlist = ''
          for k,v in pairs(list) do
            banlist = banlist .. k .. " - " .. v .. "\n"
          end
          if banlist == '' then
            banlist = 'There are currently no banned users.'
          else
            banlist = 'Banned users list:\n\n' .. banlist
          end
          return banlist
        end

        -- List of group's moderators
        if msg.text == '!modlist' and is_administrate(msg, gid) then
          get_modlist(msg, gid)
        end
      end

      -- Kick per user's request. Don't do this in supergroup, because that's mean ban
      if matches[1] == 'kickme' or matches[1] == 'leave' then
        if msg.to.peer_type == 'channel' then
          reply_msg(msg.id, 'Leave this group manually or you will be unable to rejoin.', ok_cb, true)
        else
          kick_user(msg, gid, uid)
        end
      end

      -- Print group's invite link. Users can join group by clicking this link.
      if matches[1] == 'link' or matches[1] == 'getlink' or matches[1] == 'link get' then
        local link = data.link
        local gtitle = msg.to.title
        if data.public or is_owner(msg, gid, uid) then
          if link == '' then
            bot_sendMessage(get_receiver_api(msg), 'No link has been set for this group.\n'
                .. 'Try `!link set` to generate.', false, msg.id, 'markdown')
          elseif link == 'revoked' then
            reply_msg(msg.id, 'Invite link for this group has been revoked', ok_cb, true)
          else
            local about = data.description
            local clickme = '<a href="' .. link .. '">Click me to join ' .. gtitle .. '</a>'
            if not about then
              bot_sendMessage(get_receiver_api(msg), '<b>' .. gtitle .. '</b>\n\n' .. clickme, false, msg.id, 'html')
            else
              bot_sendMessage(get_receiver_api(msg), '<b>' .. gtitle .. '</b>\n\n' .. about .. '\n\n' .. clickme, false, msg.id, 'html')
            end
          end
        else
          reply_msg(msg.id, 'This group is private.', ok_cb, true)
        end
      end

      -- Print group's description.
      if matches[1] == 'about' then
        local about = data.description
        if not about then
          reply_msg(msg.id, 'No description available', ok_cb, true)
        else
          bot_sendMessage(get_receiver_api(msg), '<b>' .. msg.to.title .. '</b>\n\n' .. about, false, msg.id, 'html')
        end
      end

      -- Print group's rules
      if matches[1] == 'rules' then
        if not data.rules then
          reply_msg(msg.id, 'No rules have been set for ' .. msg.to.title .. '.', ok_cb, true)
        else
          local rules = data.rules
          local rules = msg.to.print_name .. ' rules:\n\n' .. rules
          reply_msg(msg.id, rules, ok_cb, true)
        end
      end

      -- List of groups managed by this bot (listed in data/config.lua)
      if matches[1] == 'grouplist' or matches[1] == 'groups' or matches[1] == 'glist' then
        local gplist = ''
        for k,v in pairs(_config.administration) do
          local gpdata = load_data(v)
          if gpdata.public then
            if gpdata.link then
              gplist = gplist .. '• [' .. gpdata.name .. '](' .. gpdata.link .. ')\n'
            else
              gplist = gplist .. '• ' .. gpdata.name .. '\n'
            end
          end
        end
        if gplist == '' then
          gplist = 'There are currently no listed groups.'
        else
          gplist = '*Groups:*\n' .. gplist
        end
        bot_sendMessage(get_receiver_api(msg), gplist, false, msg.id, 'markdown')
      end

      -- print merbot version
      if matches[1] == "version" then
        reply_msg(msg.id, 'Merbot\n' .. VERSION .. '\nGitHub: ' .. bot_repo .. '\n'
             .. 'License: GNU GPL v2', ok_cb, true)
      end

    else -- if in private message

      local usr = get_username(msg)

      if is_sudo(uid) then
        --TODO update_members_list an set_group_link not working in private message
--        if matches[1] == 'addgroup' or matches[1] == 'gadd' then
--          add_group(msg, matches[2], uid)
--        end

        if matches[1] == 'remgroup' or matches[1] == 'grem' or matches[1] == 'gremove' then
          remove_group(msg, matches[2])
        end

        if matches[1] == 'adminprom' or matches[1] == 'admin' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            promote_admin({msg=msg, usr=usr}, matches[4])
          end
        end

        if matches[1] == 'admindem' or matches[1] == 'deadmin' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            demote_admin({msg=msg, usr=usr}, matches[4])
          end
        end
      end

      if is_admin(uid) then
        if matches[1] == 'setowner' or matches[1] == 'gov' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            promote_owner({msg=msg, usr=usr}, matches[4], matches[3])
          end
        end

        if matches[1] == 'remowner' or matches[1] == 'degov' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            demote_owner({msg=msg, usr=usr}, matches[4], matches[3])
          end
        end

        if matches[1] == 'promote' or matches[1] == 'mod' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            promote_owner({msg=msg, usr=usr}, matches[4], matches[3])
          end
        end

        if matches[1] == 'demote' or matches[1] == 'demod' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            demote_owner({msg=msg, usr=usr}, matches[4], matches[3])
          end
        end

        if matches[1] == 'ownerlist' then
          get_ownerlist(msg, matches[2])
        end

        if matches[1] == 'superban' or matches[1] == 'gban' or matches[1] == 'hammer' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            global_ban_user({msg=msg, usr=usr}, gid, matches[3])
          end
        end

        if matches[1] == 'superunban' or matches[1] == 'gunban' or matches[1] == 'unhammer' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            global_unban_user({msg=msg, usr=usr}, matches[3])
          end
        end

        if matches[1] == 'whitelist' then
          if matches[2] == 'chat' then
            redis:sadd('whitelist', matches[3])
            reply_msg(msg.id, 'Chat ' .. matches[3] .. ' whitelisted', ok_cb, true)
          end
        end

        if matches[1] == 'unwhitelist' then
          if matches[2] == 'chat' then
            redis:srem('whitelist', matches[3])
            reply_msg(msg.id, 'Chat ' .. matches[3] .. ' removed from whitelist', ok_cb, true)
          end
        end

        if matches[1] == 'kick' then
          if matches[2] == '@' then
            resolve_username(matches[3], resolve_username_cb, {msg=msg, matches=matches})
          elseif matches[3]:match('^%d+$') then
            kick_user(msg, matches[4], matches[3])
          end
        end
      end
    end

  end -- main function end here



  return {
    run = run,
    pre_process = pre_process,
    description = 'Administration plugin.',
    patterns = {
      '^!(about)$',
      '^!(adminlist)$', '^!(adminlist) (%d+)$',
      '^!(antispam) (%a+)$',
      '^!(arabic) (%a+)$',
      '^!(autoleave) (%a+)$',
      '^!(banlist)$',
      '^!(bc) (%d+) (.*)$',
      '^!(broadcast) (.*)$',
      '^!(channel) (%a+)$',
      '^!(clear) (%a+)$',
      '^!(getconfig)$', '^!(getconfig) (%d+)$',
      '^!(grouplist)$', '^!(groups)$', '^!(glist)$',
      '^!(joinrealm)$',
      '^!(kickme)$',
      '^!(leave)$',
      '^!(leaveall)$',
      '^!(link revoke)$',
      '^!(mkgroup) (.*)$',
      '^!(add)(realm)$',
      '^!(mk)(realm) (.*)$',
      '^!(removerealm)$',
      '^!(mksupergroup) (.*)$',
      '^!(modlist)$', '^!(modlist) (%d+)$',
      '^!(ownerlist)$', '^!(ownerlist) (%d+)$',
      '^!(rules)$',
      '^!(setabout) (.*)$',
      '^!(setname) (.*)$',
      '^!(setphoto)$',
      '^!(setprivate)$',
      '^!(setpublic)$',
      '^!(setrules) (.*)$',
      '^!(setwelcome) (.*)$',
      '^!(resetwelcome)$',
      '^!(sticker) (%a+)$',
      '^!(sudolist)$',
      '^!(unwhitelist) (chat) (%d+)$',
      '^!(version)$',
      '^!(welcome) (%a+)$',
      '^!(whitelist) (%a+)$',
      '^!(whitelist) (chat) (%d+)$',
      '^!(superbanlist)$', '^!(gbanlist)$', '^!(hammerlist)$',
      '^!(whitelist)$', '^!(whitelist) (@)(%g+)$', '^!(whitelist)(%s)(%d+)$',
      '^!(unwhitelist)$', '^!(unwhitelist) (%g+)$', '^!(unwhitelist) (@)(%g+)$', '^!(unwhitelist)(%s)(%d+)$',
      '^!(addgroup)$', '^!(gadd)$', '^!(addgroup) (%d+)$', '^!(gadd) (%d+)$',
      '^!(visudo)$', '^!(visudo) (@)(%g+)$', '^!(visudo)(%s)(%d+)$', '^!(visudo) (@)(%g+) (%d+)$', '^!(visudo)(%s)(%d+) (%d+)$',
      '^!(sudo)$', '^!(sudo) (@)(%g+)$', '^!(sudo)(%s)(%d+)$', '^!(sudo) (@)(%g+) (%d+)$', '^!(sudo)(%s)(%d+) (%d+)$',
      '^!(desudo)$', '^!(desudo) (@)(%g+)$', '^!(desudo)(%s)(%d+)$', '^!(desudo) (@)(%g+) (%d+)$', '^!(desudo)(%s)(%d+) (%d+)$',
      '^!(admin)$', '^!(admin) (@)(%g+)$', '^!(admin)(%s)(%d+)$', '^!(admin) (@)(%g+) (%d+)$', '^!(admin)(%s)(%d+) (%d+)$',
      '^!(adminprom)$', '^!(adminprom) (@)(%g+)$', '^!(adminprom)(%s)(%d+)$', '^!(adminprom) (@)(%g+) (%d+)$', '^!(adminprom)(%s)(%d+) (%d+)$',
      '^!(ban)$', '^!(ban) (@)(%g+)$', '^!(ban)(%s)(%d+)$', '^!(ban) (%w+)(%s)(%d+)$',
      '^!(deadmin)$', '^!(deadmin) (@)(%g+)$', '^!(deadmin)(%s)(%d+)$', '^!(deadmin) (@)(%g+) (%d+)$', '^!(deadmin)(%s)(%d+) (%d+)$',
      '^!(admindem)$', '^!(admindem) (@)(%g+)$', '^!(admindem)(%s)(%d+)$', '^!(admindem) (@)(%g+) (%d+)$', '^!(admindem)(%s)(%d+) (%d+)$',
      '^!(demote)$', '^!(demote) (@)(%g+)$', '^!(demote)(%s)(%d+)$',
      '^!(demod)$', '^!(demod) (@)(%g+)$', '^!(demod)(%s)(%d+)$',
      '^!(grem)$', '^!(grem) (%d+)$', '^!(gremove)$', '^!(gremove) (%d+)$', '^!(remgroup)$', '^!(remgroup) (%d+)$',
      '^!(group) (lock) (%a+)$', '^!(gp) (lock) (%a+)$',
      '^!(group) (settings)$', '^!(gp) (settings)$',
      '^!(group) (unlock) (%a+)$', '^!(gp) (unlock) (%a+)$',
      '^!(invite)$', '^!(invite) (enable)$', '^!(invite) (disable)$', '^!(invite) (@)(%g+)$', '^!(invite)(%s)(%g+)$',
      '^!(kick)$', '^!(kick) (@)(%g+)$', '^!(kick)(%s)(%d+)$', '^!(kick) (%d+) (%d+)$', '^!(kick) (@)(%g+) (%d+)$', '^!(kick)(%s)(%d+) (%d+)$',
      '^!(link)$', '^!(link get)$', '^!(getlink)$',
      '^!(link set)$', '^!(setlink)$', '^!(link set) (.*)$', '^!(setlink) (.*)$',
      '^!(setowner)$', '^!(setowner) (@)(%g+)$', '^!(setowner)(%s)(%d+)$', '^!(setowner) (@)(%g+) (%d+)$', '^!(setowner)(%s)(%d+) (%d+)$',
      '^!(gov)$', '^!(gov) (@)(%g+)$', '^!(gov)(%s)(%d+)$', '^!(gov) (@)(%g+) (%d+)$', '^!(gov)(%s)(%d+) (%d+)$',
      '^!(degov)$', '^!(degov) (@)(%g+)$', '^!(degov)(%s)(%d+)$', '^!(degov) (@)(%g+) (%d+)$', '^!(degov)(%s)(%d+) (%d+)$',
      '^!(remowner)$', '^!(remowner) (@)(%g+)$', '^!(remowner)(%s)(%d+)$', '^!(remowner) (@)(%g+) (%d+)$', '^!(remowner)(%s)(%d+) (%d+)$',
      '^!(mod)$', '^!(mod) (@)(%g+)$', '^!(mod)(%s)(%d+)$', '^!(mod) (@)(%g+) (%d+)$', '^!(mod)(%s)(%d+) (%d+)$',
      '^!(promote)$', '^!(promote) (@)(%g+)$', '^!(promote)(%s)(%d+)$', '^!(promote) (@)(%g+) (%d+)$', '^!(promote)(%s)(%d+) (%d+)$',
      '^!(superban)$', '^!(superban) (@)(%g+)$', '^!(superban)(%s)(%d+)$', '^!(superban) (@)(%g+) (%d+)$', '^!(superban)(%s)(%d+) (%d+)$',
      '^!(hammer)$', '^!(hammer) (@)(%g+)$', '^!(hammer)(%s)(%d+)$', '^!(hammer) (@)(%g+) (%d+)$', '^!(hammer)(%s)(%d+) (%d+)$',
      '^!(gban)$', '^!(gban) (@)(%g+)$', '^!(gban)(%s)(%d+)$', '^!(gban)(%s)(%d+) (%d+)$', '^!(gban) (@)(%g+) (%d+)$',
      '^!(superunban)$', '^!(superunban) (@)(%g+)$', '^!(superunban)(%s)(%d+)$', '^!(superunban) (@)(%g+) (%d+)$', '^!(superunban)(%s)(%d+) (%d+)$',
      '^!(unhammer)$', '^!(unhammer) (@)(%g+)$', '^!(unhammer)(%s)(%d+)$', '^!(unhammer) (@)(%g+) (%d+)$', '^!(unhammer)(%s)(%d+) (%d+)$',
      '^!(gunban)$', '^!(gunban) (@)(%g+)$', '^!(gunban)(%s)(%d+)$', '^!(gunban) (@)(%g+) (%d+)$', '^!(gunban)(%s)(%d+) (%d+)$',
      '^!(unban)$', '^!(unban) (@)(%g+)$', '^!(unban)(%s)(%d+)$', '^!(unban) (%g+) (%d+)$',
      '^!!tgservice (.+)$',
      '%[(audio)%]',
      '%[(document)%]',
      '%[(photo)%]',
      '%[(video)%]',
    },
    usage = {
      sudo = {
        '<a href="https://telegram.me/thefinemanual/6">Autoleave</a>',
        '<a href="https://telegram.me/thefinemanual/7">Sudo</a>',
        '<a href="https://telegram.me/thefinemanual/10">Administrator</a>',
      },
      admin = {
        '<a href="https://telegram.me/thefinemanual/11">Create Group</a>',
        '<a href="https://telegram.me/thefinemanual/12">Invitation</a>',
        '<a href="https://telegram.me/thefinemanual/13">Global Ban</a>',
        '<a href="https://telegram.me/thefinemanual/14">Add and Remove Group</a>',
        '<a href="https://telegram.me/thefinemanual/15">Channel</a>',
        '<a href="https://telegram.me/thefinemanual/16">Whitelist</a>',
        '<a href="https://telegram.me/thefinemanual/17">Administrator List</a>',
        '<a href="https://telegram.me/thefinemanual/18">Group Owner</a>',
      },
      owner = {
        '<a href="https://telegram.me/thefinemanual/20">Group Settings</a>',
        '<a href="https://telegram.me/thefinemanual/21">Whitelist</a>',
        '<a href="https://telegram.me/thefinemanual/22">Anti Spam</a>',
        '<a href="https://telegram.me/thefinemanual/29">Arabic script restriction</a>',
        '<a href="https://telegram.me/thefinemanual/23">Group Promotion</a>',
        '<a href="https://telegram.me/thefinemanual/24">Invitation</a>',
        '<a href="https://telegram.me/thefinemanual/25">Kick</a>',
        '<a href="https://telegram.me/thefinemanual/26">Ban</a>',
        '<a href="https://telegram.me/thefinemanual/27">Moderators List</a>',
      },
      moderator = {
        '<a href="https://telegram.me/thefinemanual/24">Invitation</a>',
        '<a href="https://telegram.me/thefinemanual/26">Ban</a>',
        '<a href="https://telegram.me/thefinemanual/25">Kick</a>',
        '<a href="https://telegram.me/thefinemanual/27">Moderators List</a>'
      },
      user = {
        '<code>!about</code>',
        'Read group description',
        '',
        '<code>!rules</code>',
        'Read group rules',
        '',
        '<code>!link get</code>',
        'Print invite link',
        '',
        '<code>!kickme</code>',
        'Kick yourself out of this group.'
      },
    },
  }

end

