
struct HQMNotification
    sender   ::Any # Who sent the notification
    userInfo ::Tuple # Any necessary data needed
end

struct HQMNotificationObject
    observer::Any
    fcn     ::Any
end

HQMNotificationCenter = Dict{String,Vector{HQMNotificationObject}}()
HQMNotificationsON    = true


"""
    addObserver(observer::Any, note::String, f::Any)

`f` is the function to be executed (called) when a
notification of name `note` is given.

The function called upon notification must have the signature
f(observer, sender, args...)
"""
function addObserver(observer::Any, note::String, f::Any)

    noteObj = HQMNotificationObject(observer,f)
    if !haskey(HQMNotificationCenter,note)
        HQMNotificationCenter[note] = HQMNotificationObject[]
    end
    push!(HQMNotificationCenter[note],noteObj)
end


"""
    unRegisterForNotification(observer::Any, note::String)

Remove the observer from being notified by the notification `note`
"""
function unRegisterForNotification(observer::Any, note::String)
    if haskey(HQMNotificationCenter,note)
        global observers = HQMNotificationCenter[note]

        for i = 1:length(observers)
            global noteObj  = observers[i]
            noteObserver = noteObj.observer
            if noteObserver === observer
                deleteat!(observers,i)
                break
            end
        end
        if isempty(observers)
            delete!(HQMNotificationCenter,note)
        end
    end
end


"""
    postNotificationWithName(sender::Any, name::String, userInfo::Tuple)

Executes the function associated with the observer for the notification `note`
"""
function postNotificationWithName(sender::Any, note::String, userInfo::Tuple)
    if haskey(HQMNotificationCenter,note) && HQMNotificationsON
        global observers = HQMNotificationCenter[note]

        for i = 1:length(observers)
            global noteObj  = observers[i]
            f        = noteObj.fcn
            observer = noteObj.observer
            if isnothing(userInfo[1])
                f(observer,sender)
            else
                f(observer,sender,userInfo...)
            end
        end
    end
end


function enableNotifications()
    global HQMNotificationsON = true
end


function disableNotifications()
    global HQMNotificationsON = false
end
