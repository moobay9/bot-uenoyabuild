# Description:
#   ご飯を迷った時に使いましょう
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot lunch add [key] [shop] [weight=1]
#   hubot lunch remove [key]
#   hubot lunch list
#   hubot lunch select
#
# URLS:
#   /lunch/:shops/

spawn = require('child_process').spawn

module.exports = (robot) ->
  robot.brain.on "loaded", (data) ->
    # if data.lunch
    #   delete data.lunch

    if ! data._private.lunch or ! data._private.lunch.shops
      robot.brain.set("lunch", {shops: []})
      robot.brain.save()

  putList = (msg) ->
    lunch = robot.brain.get("lunch")
    text = "登録されてるご飯処です〜\n"
    for key, shop of lunch.shops
      text += "{key: #{shop.key}, shop: #{shop.shop}, weight: #{shop.weight}}\n"
    msg.send text

  robot.respond /lunch add (.*) (.*) (.*)/i, (msg) ->
    key    = msg.match[1]
    shop   = msg.match[2]
    weight = msg.match[3] or 5
    lunch  = robot.brain.get "lunch"
    is_key = 0

    for k, _shop of lunch.shops
      if _shop.key == key
        is_key = 1

    if is_key == 0
      lunch.shops.push {key, shop, weight}
      robot.brain.set  "lunch", lunch
      robot.brain.save()

    putList(msg)

  # robot.respond /lunch clear/i, (msg) ->
  #   lunch = robot.brain.get "lunch"
  #   lunch.shops = []
  #   robot.brain.set("lunch", lunch)
  #   robot.brain.save()
  #   msg.send "現在の在室情況をクリアしたよ！"

  robot.respond /lunch (remove|delete) (.*)/i, (msg) ->
    lunch = robot.brain.get "lunch"
    key   = msg.match[2]
    for k, shop of lunch.shops
      if shop.key == key
        robot.logger.debug k
        lunch.shops.splice(k, 1)
        robot.brain.set "lunch", lunch
    putList(msg)

  robot.respond /lunch list/i, (msg) ->
    putList(msg)

  robot.respond /lunch select/i, (msg) ->
    lunch = robot.brain.get "lunch"
    shops = lunch.shops
    total = 0
    score = 0

    shops.sort (a, b) ->
      (if parseInt(a.weight, 10) < parseInt(b.weight, 10) then 1 else -1)

    robot.logger.debug shops

    # SUM
    for k, shop of shops
      total += parseInt(shop.weight, 10)
    
    robot.logger.debug "total: #{total}"

    # Weight
    for k, shop of shops
      weight = Math.random() * total
      score += parseInt(shop.weight, 10)

      robot.logger.debug "weight: #{weight}"
      robot.logger.debug "score:  #{score}"

      if weight < score
        text = shop.shop
        break

    msg.send "今日のお昼はこちら！\n #{text}"
