###*
# 任务并行控制
# @author yy
###

async   = require 'async'
gutil   = require 'gulp-util'



###任务控制类###
###
#param:
#num        number    任务数量
#saturated  function  监听：如果某次push操作后，任务数将达到或超过worker数量时，将调用该函数
#empty      function  监听：当最后一个任务交给worker时，将调用该函数
#drain      function  监听：当所有任务都执行完以后，将调用该函数
###
class taskCtrl
    constructor:(obj) ->
        _obj = obj or {}

        num = obj.num or 5
        saturated = obj.saturated or ->
        empty = obj.empty or ->
        drain = obj.drain or ->

        queue = @init(num)

        queue.saturated = saturated
        queue.empty = empty
        queue.drain = drain

        @queue = queue
    init: (num) ->
        queue = async.queue (task,cb)->
            gutil.log "task:#{task.name} run;wait:#{queue.length()}"
            task.run cb
        ,num
    add: (obj,endFn) ->#obj:name--任务名称  task--任务function   endFn:任务结束后执行
        _obj = obj or {}
        _name = _obj.name or ''
        _task = _obj.task or ->
        _endFn = endFn or ->

        @queue.push 
            name: _name
            run: (cb) ->
                _task cb
        ,(err) ->
            _endFn(err)



module.exports = taskCtrl