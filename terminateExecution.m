function terminateExecution
    % Exit a programme even from within a try/catch pair.
    
    import java.awt.event.KeyEvent
    import java.lang.reflection.*

    base = com.mathworks.mde.cmdwin.CmdWin.getInstance();
    hCmd = base.getComponent(0).getViewport().getView();
    cmdwin = handle(hCmd,'CallbackProperties');

    argSig = javaArray('java.lang.Class',1);
    argSig(1) = java.lang.Class.forName('java.awt.event.KeyEvent');

    msTime = (8.64e7 * (now - datenum('1970', 'yyyy')));
    args = javaArray('java.lang.Object',1);
    args(1) = KeyEvent(cmdwin,KeyEvent.KEY_PRESSED,msTime,...
        KeyEvent.CTRL_DOWN_MASK,KeyEvent.VK_C,KeyEvent.CHAR_UNDEFINED);

    method = cmdwin.getClass().getDeclaredMethod('processKeyEvent',argSig);
    method.setAccessible(true);
    method.invoke(cmdwin,args);
end