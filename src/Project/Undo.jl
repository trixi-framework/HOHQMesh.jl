
struct UROperation
    object::Any
    action::Any
    data  ::Tuple
    name  ::String
end

@enum UNDO_OPERATION_TYPE begin
   UNDO_USER_OPERATION = 0
   UNDO_OPERATION      = 1
   REDO_OPERATION      = 2
   UNDO_IGNORE         = 3
end

#=
TODO: The undo framework currently works globally, within the REPL. It *should* work project-by-project.
Note that these projects refer to the interactive mesh functionality projects,
not Julia projects in the sense of `Project.toml`.
To make the undo framework project based, undo() would be replaced by undo(project) and an .undoStack
property of the project would replace HQMglobalUndoStack. This is
not a big deal except if multiple projects are open, and multiple objects like curves have been
defined but not added to a project. In interactive mode curves are separate from projects until
added. (The same curve could be added to multiple projects.) So some logic needs to be
figured out before modifying below. If only one project is managed per session,
then this is not a problem.
=#
HQMglobalUndoStack = []
HQMglobalRedoStack = []
HQMglobalChangeOP  = UNDO_IGNORE


function undo()
    if !isempty(HQMglobalUndoStack)
        op  = pop!(HQMglobalUndoStack)
        f   = op.action
        d   = op.data
        obj = op.object
        global HQMglobalChangeOP = UNDO_OPERATION
        if isnothing(d[1])
            f(obj)
        else
            f(obj,d...)
        end
        global HQMglobalChangeOP = UNDO_USER_OPERATION
        return "Undo "*op.name
    end
    return "Empty undo stack. No action performed."
end


function redo()
    if !isempty(HQMglobalRedoStack)
        op  = pop!(HQMglobalRedoStack)
        f   = op.action
        d   = op.data
        obj = op.object
        global HQMglobalChangeOP = REDO_OPERATION
        if isnothing(d[1])
            f(obj)
        else
            f(obj,d...)
        end
        global HQMglobalChangeOP = UNDO_USER_OPERATION
        return "Redo " * op.name
    end
    return "Empty redo stack. No action performed."
end


function registerUndo(obj, action, data::Tuple, name::String)
    uOp = UROperation(obj,action,data,name)
    push!(HQMglobalUndoStack,uOp)
end


function registerWithUndoManager(obj, action, oldData::Tuple, name::String)

    if HQMglobalChangeOP == UNDO_USER_OPERATION #User action
        registerUndo(obj,action,oldData,name)
    elseif HQMglobalChangeOP == UNDO_OPERATION #Undo operation
        registerRedo(obj,action,oldData,name)
    elseif HQMglobalChangeOP == REDO_OPERATION #Redo operation
        registerUndo(obj,action,oldData,name)
    else
        # UNDO_IGNORE
    end
end

function registerRedo(obj, action, data::Tuple, name::String)
    rOp = UROperation(obj,action,data,name)
    push!(HQMglobalRedoStack,rOp)
end


function clearUndoRedo()
        empty!(HQMglobalUndoStack)
        empty!(HQMglobalRedoStack)
end


function undoActionName()
    if !isempty(HQMglobalUndoStack)
        op = last(HQMglobalUndoStack)
        return op.name
    end
    return "No undo action in queue"
end


function redoActionName()
    if !isempty(HQMglobalRedoStack)
        op = last(HQMglobalRedoStack)
        return op.name
    end
    return "No redo action in queue"
end


function disableUndo()
     global HQMglobalChangeOP = UNDO_IGNORE
end


function enableUndo()
    global HQMglobalChangeOP = UNDO_USER_OPERATION
end
