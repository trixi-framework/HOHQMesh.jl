#=
 MIT License

 Copyright (c) 2010-present David A. Kopriva and other contributors: AUTHORS.md

 Permission is hereby granted, free of charge, to any person obtaining a copy  
 of this software and associated documentation files (the "Software"), to deal  
 in the Software without restriction, including without limitation the rights  
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
 copies of the Software, and to permit persons to whom the Software is  
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all  
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
 SOFTWARE.
 
 --- End License
=#

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
    addObserver(observer::Any, note::String, fnction::Any)

fnction is the function to be executed (called) when a 
notification of name `note` is given.

The function called upon notification must have the signature
fnction(observer, sender, args...)
"""
function addObserver(observer::Any, note::String, fnction::Any)

    noteObj = HQMNotificationObject(observer,fnction)
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
