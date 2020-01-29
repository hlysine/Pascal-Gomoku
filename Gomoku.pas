program Gomoku;
uses crt,sysutils;
{----------game data structure----------}
const boardSize = 15;
      winCount = 5;
      defaultScrWidth = 120;
      defaultScrHeight = 45;
type 
    state = (p1,p2,null);
    game = record
        playTurn : state;
        board : array[1..boardSize,1..boardSize] of state;
        winner : state;
        moveCount : integer;
        gameOver : boolean;
    end;

procedure initGame(var g : game);
var i,j : integer;
begin
    g.moveCount := 0;
    g.gameOver := false;
    g.winner := null;
    g.playTurn := p1;
    for i := 1 to boardSize do
        for j := 1 to boardSize do
            g.board[i,j] := null;
end;

{
    4 check functions for four directions from the center
    (the location of the new move)
    *   *   *
     *  *  *
      * * *
       ***
    ****X****
       ***
      * * *
     *  *  *
    *   *   *
}
function chkRow(g : game; x,y : integer) : boolean;
var i,count : integer;
begin
    count := 0;
    i := 1;
    while (x-i>=1) and (i<winCount) and (count<winCount) and (g.board[x-i,y] = g.board[x,y]) do
    begin
        i := i + 1;
    end;
    count := count + i;
    if count >= winCount then
        chkRow := true
    else
    begin
        i := 1;
        while (x+i<=boardSize) and (i<winCount) and (count<winCount) and (g.board[x+i,y] = g.board[x,y]) do
        begin
            i := i + 1;
            count := count + 1;
        end;
        if count - 1 >= winCount then
            chkRow := true
        else chkRow := false;
    end;
end;

function chkCol(g : game; x,y : integer) : boolean;
var i,count : integer;
begin
    count := 0;
    i := 1;
    while (y-i>=1) and (i<winCount) and (count<winCount) and (g.board[x,y-i] = g.board[x,y]) do
    begin
        i := i + 1;
    end;
    count := count + i;
    if count >= winCount then
        chkCol := true
    else
    begin
        i := 1;
        while (y+i<=boardSize) and (i<winCount) and (count<winCount) and (g.board[x,y+i] = g.board[x,y]) do
        begin
            i := i + 1;
            count := count + 1;
        end;
        if count-1 >= winCount then
            chkCol := true
        else chkCol := false;
    end;
end;

function chkDiagonalTopLeft(g : game; x,y:integer) : boolean;
var i,count : integer;
begin
    count := 0;
    i := 1;
    while (y-i>=1) and (x-i>=1) and (i<winCount) and (count<winCount) and (g.board[x-i,y-i] = g.board[x,y]) do
    begin
        i := i + 1;
    end;
    count := count + i;
    if count >= winCount then
        chkDiagonalTopLeft := true
    else
    begin
        i := 1;
        while (y+i<=boardSize) and (x+i<=boardSize) and (i<winCount) and (count<winCount) and (g.board[x+i,y+i] = g.board[x,y]) do
        begin
            i := i + 1;
            count := count + 1;
        end;
        if count-1 >= winCount then
            chkDiagonalTopLeft := true
        else chkDiagonalTopLeft := false;
    end;
end;

function chkDiagonalTopRight(g : game; x,y:integer) : boolean;
var i,count,offset : integer;
begin
    count := 0;
    i := 1;
    while (y-i>=1) and (x+i<=boardSize) and (i<winCount) and (count<winCount) and (g.board[x+i,y-i] = g.board[x,y]) do
    begin
        i := i + 1;
    end;
    count := count + i;
    if count >= winCount then
        chkDiagonalTopRight := true
    else
    begin
        i := 1;
        while (y+i<=boardSize) and (x-i>=1) and (i<winCount) and (count<winCount) and (g.board[x-i,y+i] = g.board[x,y]) do
        begin
            i := i + 1;
            count := count + 1;
        end;
        if count-1 >= winCount then
            chkDiagonalTopRight := true
        else chkDiagonalTopRight := false;
    end;
end;

function move(var g : game; mX,mY : integer) : boolean;
var won : boolean;
begin
    if g.board[mx,my] = null then
    begin
        g.board[mx,my] := g.playTurn;
        g.moveCount := g.moveCount + 1;

        {assume draw if board full}
        if (g.moveCount = sqr(boardSize)) then
        begin
            g.winner := null;
            g.gameOver := true;
        end;

        {check winning}
        won := false;
        won := won or chkRow(g,mX,mY);
        won := won or chkCol(g,mX,mY);
        won := won or chkDiagonalTopLeft(g,mX,mY);
        won := won or chkDiagonalTopRight(g,mX,mY);
        if won then
        begin
            g.winner := g.playTurn;
            g.gameOver := true;
        end;

        if g.playTurn = p1 then
            g.playTurn := p2
        else
            g.playTurn := p1;

        move := true;
    end
    else
    begin
        move := false;
    end;
end;

function hasNeighbor(g:game;x,y:integer):boolean;
begin
    hasNeighbor := ((x+1<=boardSize) and (g.board[x+1,y]<>null)) or
                   ((x-1>0) and (g.board[x-1,y]<>null)) or
                   ((y+1<=boardSize) and (g.board[x,y+1]<>null)) or
                   ((y-1>0) and (g.board[x,y-1]<>null)) or
                   ((x+1<=boardSize) and (y+1<=boardSize) and (g.board[x+1,y+1]<>null)) or
                   ((x-1>0) and (y-1>0) and (g.board[x-1,y-1]<>null)) or
                   ((x-1>0) and (y+1<=boardSize) and (g.board[x-1,y+1]<>null)) or
                   ((x+1<=boardSize) and (y-1>0) and (g.board[x+1,y-1]<>null));
end;

{----------AI----------}
const maxDepth = 5;
function alphaBetaPruning(p : State; var g : game; alpha,beta : integer; currentDepth : integer) : integer; forward;
function score(p : State; g : game) : integer;
begin
    if (g.gameOver) and (g.winner = p) then
        score := 10
    else if (g.gameOver) and (g.winner = null) then
        score := 0
    else if (g.gameOver) then
        score := -10
    else    
        score := 0
end;
function getMin(p : State; var g : game; alpha,beta : integer; currentDepth : integer) : integer;
var mx,my : integer; {best move}
    i,j : integer;
    mg : game;
    mScore : integer;
    pruned : boolean;
begin
    mx := -1;
    my := -1;
    pruned := false;
    for i := 1 to boardSize do
    begin
        for j := 1 to boardSize do
        begin
            if (g.board[i,j] = null) and ((boardSize < 4) or hasNeighbor(g,i,j)) and not pruned then
            begin
                mg := g;
                move(mg,i,j);
                mScore := alphaBetaPruning(p,mg,alpha,beta,currentDepth);
                if (mScore < beta) then
                begin
                    beta := mScore;
                    mx := i;
                    my := j;
                end;
                if (alpha >= beta) then
                    pruned := true;
            end;
        end;
    end;
    if (mx <> -1) and (my <> -1) then
    begin
        move(g,mx,my);
    end;
    getMin := beta;
end;
function getMax(p : State; var g : game; alpha,beta : integer; currentDepth : integer) : integer;
var mx,my : integer; {best move}
    i,j : integer;
    mg : game;
    mScore : integer;
    pruned : boolean;
begin
    mx := -1;
    my := -1;
    pruned := false;
    for i := 1 to boardSize do
    begin
        for j := 1 to boardSize do
        begin
            if (g.board[i,j] = null) and ((boardSize < 4) or hasNeighbor(g,i,j)) and not pruned then
            begin
                mg := g;
                move(mg,i,j);
                mScore := alphaBetaPruning(p,mg,alpha,beta,currentDepth);
                if (mScore > alpha) then
                begin
                    alpha := mScore;
                    mx := i;
                    my := j;
                end;
                if (alpha >= beta) then
                    pruned := true;
            end;
        end;
    end;
    if (mx <> -1) and (my <> -1) then
    begin
        move(g,mx,my);
    end;
    getMax := alpha;
end;
function alphaBetaPruning(p : State; var g : game; alpha,beta : integer; currentDepth : integer) : integer;
begin
    currentDepth := currentDepth + 1;
    if (currentDepth = maxDepth) or (g.gameOver) then
        alphaBetaPruning := score(p,g)
    else
    begin
        if g.playTurn = p then
            alphaBetaPruning := getMax(p, g, alpha, beta, currentDepth)
        else
            alphaBetaPruning := getMin(p, g, alpha, beta, currentDepth);
    end;
end;
procedure AIplay(p : State; var g : game);
var alpha,beta : integer;
begin
    alpha := -MAXINT-1;
    beta := MAXINT;
    alphaBetaPruning(p,g,alpha,beta,0);
end;

{----------MAIN GAME----------}
const configdir = 'config.txt';
      savedir = 'data.txt';
var g : game;
    x,y,i,j,lx,ly,lx2,ly2 : integer;
    selection : integer;
    c : char;
    vsHuman : boolean; 
    scrWidth,scrHeight : integer;
    gamedir : string;
    configfile,savefile,gamefile : textfile;
    saveLoaded : boolean;
    p1winCount,p2winCount,p2drawCount,pwinCount,ploseCount,pdrawCount : integer;
procedure loadConfig;
begin
    if FileExists(configdir) then
    begin
        assign(configfile,configdir);
        reset(configfile);
        readln(configfile,scrWidth);
        readln(configfile,scrHeight);
        close(configfile);
    end
    else
    begin
        scrWidth := defaultScrWidth;
        scrHeight := defaultScrHeight;
        assign(configfile,configdir);
        rewrite(configfile);
        write(configfile,scrWidth);
        writeln(configfile,' <- screen width');
        write(configfile,scrHeight);
        writeln(configfile,' <- screen height');
        close(configfile);
    end;
end;
procedure loadSave;
begin
    if FileExists(savedir) then
    begin
        assign(savefile,savedir);
        reset(savefile);
        readln(savefile,p1winCount);
        readln(savefile,p2winCount);
        readln(savefile,p2drawCount);
        readln(savefile,pwinCount);
        readln(savefile,ploseCount);
        readln(savefile,pdrawCount);
        close(savefile);
        saveloaded := true;
    end
    else
    begin
        p1winCount  := 0;
        p2winCount  := 0;
        p2drawCount := 0;
        pwinCount   := 0;
        ploseCount  := 0;
        pdrawCount  := 0;

        assign(savefile,savedir);
        rewrite(savefile);
        writeln(savefile,p1winCount);
        writeln(savefile,p2winCount);
        writeln(savefile,p2drawCount);
        writeln(savefile,pwinCount);
        writeln(savefile,ploseCount);
        writeln(savefile,pdrawCount);
        close(savefile);
        saveloaded := false;
    end;
end;
procedure saveSave;
begin
    assign(savefile,savedir);
    rewrite(savefile);
    writeln(savefile,p1winCount);
    writeln(savefile,p2winCount);
    writeln(savefile,p2drawCount);
    writeln(savefile,pwinCount);
    writeln(savefile,ploseCount);
    writeln(savefile,pdrawCount);
    close(savefile);
    saveloaded := false;
end;
procedure writeTurnMarker(whoseTurn : state);
begin
    gotoxy(1,4);
    textcolor(black);
    textbackground(green);
    writeln('Move ':2+scrWidth div 2,g.moveCount + 1,'':(scrWidth+1) div 2 - 3);
    if whoseTurn = p1 then
    begin
        {turn marker - white}
        textcolor(yellow);
        textbackground(blue);
        gotoxy(7,scrHeight div 2 - 2);
        write('             ');
        gotoxy(7,scrHeight div 2 - 1);
        write(' Your turn   ');
        gotoxy(7,scrHeight div 2);
        write('             ');
        {turn marker - black}
        textbackground(green);
        gotoxy(scrWidth - 18,scrHeight div 2 - 2);
        write('':13);
        gotoxy(scrWidth - 18,scrHeight div 2 - 1);
        write('':13);
        gotoxy(scrWidth - 18,scrHeight div 2);
        write('':13);
        {resign button - player 1}
        gotoxy(1,scrHeight - 3);
        textcolor(yellow);
        textbackground(red);
        write('   Resign (R) ');
        {resign button - player 2}
        gotoxy(scrWidth - 13,scrHeight - 3);
        textbackground(green);
        write('':14);
        textcolor(black);
        textbackground(green);
        gotoxy(scrWidth div 2 - 11,scrHeight - 5);
        write('WASD to select      ');
        gotoxy(scrWidth div 2 - 11,scrHeight - 4);
        write('F to make the move    ');
    end
    else
    begin
        {turn marker - white}
        textbackground(green);
        gotoxy(7,scrHeight div 2 - 2);
        write('':13);
        gotoxy(7,scrHeight div 2 - 1);
        write('':13);
        gotoxy(7,scrHeight div 2);
        write('':13);
        {turn marker - black}
        textcolor(yellow);
        textbackground(blue);
        gotoxy(scrWidth - 18,scrHeight div 2 - 2);
        write('             ');
        gotoxy(scrWidth - 18,scrHeight div 2 - 1);
        if vsHuman then
            write('   Your turn ')
        else
            write(' Thinking... ');
        gotoxy(scrWidth - 18,scrHeight div 2);
        write('             ');
        {resign button - player 1}
        gotoxy(1,scrHeight - 3);
        textbackground(green);
        write('':14);
        if (vsHuman) then
        begin
            {resign button - player 2}
            gotoxy(scrWidth - 13,scrHeight - 3);
            textcolor(yellow);
            textbackground(red);
            write(' Resign (L)   ');
        end;
        textcolor(black);
        textbackground(green);
        gotoxy(scrWidth div 2 - 11,scrHeight - 5);
        write('Arrow keys to select');
        gotoxy(scrWidth div 2 - 11,scrHeight - 4);
        write('Enter to make the move');
    end;
end;
procedure writeTicTacToePlayBtn(x,y:integer;placed:boolean;placable:boolean;p:state);
begin
    if placed then
    begin
        if p = p1 then
            textbackground(white)
        else if p = p2 then
            textbackground(black)
        else   
            textbackground(green);
        gotoxy(scrWidth div 2 - boardSize * 3 div 2 + 1+(x-1)*3,6+(y-1)*2);
        write('':2);
    end
    else
    begin
        if placable then
        begin
            textbackground(green);
            if p = p1 then
                textcolor(white)
            else if p = p2 then
                textcolor(black);
            gotoxy(scrWidth div 2 - boardSize * 3 div 2 + 1+(x-1)*3,6+(y-1)*2);
            write('||');
        end
        else
        begin
            textcolor(darkgray);
            if g.board[x,y] = p1 then
                textbackground(white)
            else if g.board[x,y] = p2 then
                textbackground(black);
            gotoxy(scrWidth div 2 - boardSize * 3 div 2 + 1+(x-1)*3,6+(y-1)*2);
            write('XX');
        end;
    end;
end;
    
procedure writeTicTacToePlayScreen;
var i,j : integer;
begin
    {clear screen}
    textbackground(green);
    clrscr;
    {information bar at the top}
    textcolor(black);
    textbackground(white);
    writeln;
    writeln('  Gomoku   ':6+scrWidth div 2,'':(scrWidth+1) div 2 - 6);
    gotoxy(1,3);
    if vsHuman then
    begin
        writeln(' Player 1','Player 2 ':scrWidth - 9);
    end
    else
    begin
        writeln(' You','CPU ':scrWidth - 4);
    end;
    textcolor(black);
    textbackground(green);
    gotoxy(1,4);
    writeln('Move ':2+scrWidth div 2,g.moveCount + 1,'':(scrWidth+1) div 2 - 3);
    {the game board}
    textcolor(blue);
    textbackground(green);
    gotoxy(scrWidth div 2 - boardSize * 3 div 2,5);
    write(#201);
    for i := 1 to boardSize - 1 do write(#205,#205,#203);
    write(#205,#205,#187);
    for i := 1 to boardSize - 1 do
    begin
        gotoxy(scrWidth div 2 - boardSize * 3 div 2,5+2*(i-1)+1);
        write(#186);
        for j := 1 to boardSize do
            write(#186:3);
        gotoxy(scrWidth div 2 - boardSize * 3 div 2,5+2*(i-1)+2);
        write(#204);
        for j := 1 to boardSize - 1 do write(#205,#205,#206);
        write(#205,#205,#185);
    end;
    gotoxy(scrWidth div 2 - boardSize * 3 div 2,5+boardSize * 2-1);
        write(#186);
    for j := 1 to boardSize do
        write(#186:3);
    gotoxy(scrWidth div 2 - boardSize * 3 div 2,5+boardSize * 2);
    write(#200);
    for i := 1 to boardSize - 1 do write(#205,#205,#202);
    write(#205,#205,#188);
    for i := 1 to boardSize do
        for j := 1 to boardSize do
            writeTicTacToePlayBtn(i,j,true,false,g.board[i,j]);
    {turn marker - white}
    textbackground(white);
    gotoxy(1,scrHeight div 2 - 2);
    write('':6);
    gotoxy(1,scrHeight div 2 - 1);
    write('':6);
    gotoxy(1,scrHeight div 2);
    write('':6);
    textcolor(yellow);
    textbackground(blue);
    gotoxy(7,scrHeight div 2 - 2);
    write('             ');
    gotoxy(7,scrHeight div 2 - 1);
    write(' Your turn   ':6);
    gotoxy(7,scrHeight div 2);
    write('             ':6);
    {turn marker - black}
    textbackground(black);
    gotoxy(scrWidth - 5,scrHeight div 2 - 2);
    write('':6);
    gotoxy(scrWidth - 5,scrHeight div 2 - 1);
    write('':6);
    gotoxy(scrWidth - 5,scrHeight div 2);
    write('':6);
    {textcolor(yellow);
    textbackground(blue);
    gotoxy(scrWidth - 18,scrHeight div 2 - 2);
    write('             ');
    gotoxy(scrWidth - 18,scrHeight div 2 - 1);
    if vsHuman then
        write('   Your turn ':6)
    else
        write(' Thinking... ':6);
    gotoxy(scrWidth - 18,scrHeight div 2);
    write('             ':6);}
    {resign button - player 1}
    gotoxy(1,scrHeight - 3);
    textcolor(yellow);
    textbackground(red);
    write('   Resign (R) ');
    {resign button - player 2}
    {gotoxy(scrWidth - 13,scrHeight - 3);
    textcolor(yellow);
    textbackground(red);
    write(' Resign (L)   ');}
    {instructions}
    textcolor(black);
    textbackground(green);
    gotoxy(scrWidth div 2 - 11,scrHeight - 5);
    write('WASD to select');
    gotoxy(scrWidth div 2 - 11,scrHeight - 4);
    write('F to make the move');
end;
procedure writeTicTacToeBtn(n : integer; highlight : boolean);
begin
    if highlight then
    begin
        textcolor(yellow);
        textbackground(blue);
    end
    else
    begin
        textcolor(lightgray);
        textbackground(black); 
    end;
    gotoxy(scrWidth-15,scrHeight-8+n*4-2);
    write(' +------------+ ');
    gotoxy(scrWidth-15,scrHeight-8+n*4-1);
    case n of 
        1:write(' |   Vs AI    | ');
        2:write(' |  Vs human  | ');
    end;
    gotoxy(scrWidth-15,scrHeight-8+n*4);
    write(' +------------+ ');
end;
procedure writeStartScrBtn(n : integer; highlight : boolean);
begin
    if highlight then
    begin
        textcolor(yellow);
        textbackground(blue);
    end
    else
    begin
        textcolor(lightgray);
        textbackground(black); 
    end;
    gotoxy(scrWidth-13,scrHeight-12+n*4-2);
    write(' +----------+ ');
    gotoxy(scrWidth-13,scrHeight-12+n*4-1);
    case n of 
        1:write(' | NEW GAME | ');
        2:write(' |  STATS   | ');
        3:write(' |   QUIT   | ');
    end;
    gotoxy(scrWidth-13,scrHeight-12+n*4);
    write(' +----------+ ');
end;
procedure writeStatsScreen;
begin
    {clear screen}
    textbackground(blue);
    clrscr;
    {stats}
    textcolor(black);
    textbackground(white);
    writeln;
    writeln('  Gomoku   ':6+scrWidth div 2,'':(scrWidth+1) div 2 - 6);
    writeln;
    textcolor(yellow);
    textbackground(blue);
    writeln('   PvC                 ');
    writeln(' ----------------------');
    writeln(' Win  : ',pwinCount);
    writeln(' Lose : ',ploseCount);
    writeln(' Draw : ',pdrawCount);
    writeln(' Total: ',pwincount + plosecount + pdrawcount);
    gotoxy(scrWidth div 2,4);
    write('   PvP                 ');
    gotoxy(scrWidth div 2,5);
    write(' ----------------------');
    gotoxy(scrWidth div 2,6);
    write(' Player 1 Win: ',p1winCount);
    gotoxy(scrWidth div 2,7);
    write(' Player 2 Win: ',p2winCount);
    gotoxy(scrWidth div 2,8);
    write(' Draw        : ',p2drawCount);
    gotoxy(scrWidth div 2,9);
    write(' Total       : ',p1wincount + p2wincount + p2drawcount);

    {instructions}
    gotoxy(scrWidth div 2 - 8,scrHeight - 3);
    write('Enter to go back');
end;
procedure writeStartScreen;
begin
    textbackground(black);
    clrscr;
    textcolor(white);
    textbackground(black);
    writeln;
    writeln;
    writeln('  #####  ####### #     # ####### #    # #     #');
    writeln(' #     # #     # ##   ## #     # #   #  #     #');
    writeln(' #       #     # # # # # #     # #  #   #     #');
    writeln(' #  #### #     # #  #  # #     # ###    #     #');
    writeln(' #     # #     # #     # #     # #  #   #     #');
    writeln(' #     # #     # #     # #     # #   #  #     #');
    writeln('  #####  ####### #     # ####### #    #  ##### ');
    gotoxy(1,scrHeight - 5);
    if saveloaded then
    begin
        writeln('Welcome back!');
        writeln('Ready to defeat the impossible AI?');
    end
    else
    begin
        writeln('It seems that this is the first time'); 
        writeln(' you play this game!');
        writeln('Can you beat the AI?');
        writeln('Good luck!');
    end;
    writeStartScrBtn(1, true);
    writeStartScrBtn(2, false);
    writeStartScrBtn(3, false);
    textcolor(lightgray);
    textbackground(black); 
end;
function GetSign(p:state):char;
begin
    if p = p1 then
        getSign := 'O'
    else if p = p2 then
        getSign := 'X'
    else
        getSign := ' ';
end;
procedure saveGame;
var i : integer;
begin
    i := 0;
    repeat 
        i := i + 1;
    until not FileExists('Game'+inttostr(i)+'.txt');
    gamedir := 'Game' + inttostr(i) + '.txt';
    assign(gamefile,gamedir);
    rewrite(gamefile);
    writeln(gamefile,'Please use a monospace font to view this text file');
    if vsHuman then
        writeln(gamefile,'Player 1 : O, Player 2 : X')
    else
        writeln(gamefile,'Player : O, CPU : X');
    writeln(gamefile,'+-+-+-+');
    writeln(gamefile,'|',getsign(g.board[1,1]),'|',getsign(g.board[2,1]),'|',getsign(g.board[3,1]),'|');
    writeln(gamefile,'+-+-+-+');
    writeln(gamefile,'|',getsign(g.board[1,2]),'|',getsign(g.board[2,2]),'|',getsign(g.board[3,2]),'|');
    writeln(gamefile,'+-+-+-+');
    writeln(gamefile,'|',getsign(g.board[1,3]),'|',getsign(g.board[2,3]),'|',getsign(g.board[3,3]),'|');
    writeln(gamefile,'+-+-+-+');
    if g.winner = null then
        writeln(gamefile,'Draw')
    else
        writeln(gamefile,getsign(g.winner),' wins');
    close(gamefile);
end;
begin
    loadConfig;
    loadSave;
    repeat
        clrscr;
        cursoroff;
        delay(100);
        selection := 1;
        writeStartScreen;
        repeat
            c := readkey;
            writeStartScrBtn(selection,false);
            if c = #0 then c := readkey;
            if c = #72 then
            begin
                if selection > 1 then
                    selection := selection - 1;
            end
            else if c = #80 then
            begin
                if selection < 3 then
                    selection := selection + 1;
            end;
            writeStartScrBtn(selection,true);
        until c = #13;
        if selection = 1 then {new game}
        begin
            textcolor(yellow);
            textbackground(blue); 
            gotoxy(scrWidth-13,scrHeight-10);
            write('              ');
            gotoxy(scrWidth-13,scrHeight-9);
            write(' > New Game   ');
            gotoxy(scrWidth-13,scrHeight-8);
            write('              ');
            writeTicTacToeBtn(1,true);
            writeTicTacToeBtn(2,false);
            selection := 1;
            repeat
                c := readkey;
                writeTicTacToeBtn(selection,false);
                if c = #0 then c := readkey;
                if c = #72 then
                begin
                    if selection > 1 then
                        selection := selection - 1;
                end
                else if c = #80 then
                begin
                    if selection < 2 then
                        selection := selection + 1;
                end;
                writeTicTacToeBtn(selection,true);
            until c = #13;
            lx := boardSize div 2;
            ly := boardSize div 2;
            lx2 := boardSize div 2;
            ly2 := boardSize div 2;
            if selection = 1 then {vs AI}
            begin
                vsHuman := false;
                initGame(g);
                writeTicTacToePlayScreen;
                repeat 
                    writeTurnMarker(g.playTurn);
                    x := lx;
                    y := ly;
                    writeTicTacToePlayBtn(x,y,false,g.board[x,y]=null,g.playTurn);
                    repeat
                        c := upcase(readkey);
                        writeTicTacToePlayBtn(x,y,true,false,g.board[x,y]);
                        {if c = #0 then c := readkey;}
                        if c = 'W' then
                        begin
                            if y > 1 then
                                y := y - 1;
                        end
                        else if c = 'S' then
                        begin
                            if y < boardSize then
                                y := y + 1;
                        end
                        else if c = 'A' then
                        begin
                            if x > 1 then
                                x := x - 1;
                        end
                        else if c = 'D' then
                        begin
                            if x < boardSize then
                                x := x + 1;
                        end
                        else if c = 'R' then
                        begin
                            gotoxy(1,scrHeight - 3);
                            textcolor(yellow);
                            textbackground(red);
                            write('   Confirm resign? (Y/N) ');
                            if upcase(readkey) = 'Y' then
                            begin
                                g.gameOver := true;
                                g.winner := p2;
                            end
                            else
                            begin
                                gotoxy(1,scrHeight - 3);
                                textbackground(green);
                                write('':25);
                                gotoxy(1,scrHeight - 3);
                                textcolor(yellow);
                                textbackground(red);
                                write('   Resign (R) ');
                            end;
                        end;
                        writeTicTacToePlayBtn(x,y,false,g.board[x,y]=null,g.playTurn);
                    until (c = 'F') and (g.board[x,y] = null) or g.gameOver;
                    lx := x;
                    ly := y;
                    if not g.gameOver then writeTicTacToePlayBtn(x,y,true,false,g.playTurn);
                    if not g.gameOver then move(g,x,y);
                    writeTurnMarker(g.playTurn);
                    if not g.gameOver then AIplay(p2,g);
                    for i := 1 to boardSize do
                        for j := 1 to boardSize do
                            writeTicTacToePlayBtn(i,j,true,false,g.board[i,j]);
                    writeTurnMarker(g.playTurn);
                until g.gameOver;
                if g.winner = p1 then
                begin
                    pwinCount := pwincount + 1;
                    gotoxy(1,scrHeight - 7);
                    writeln(' __          _______ _   _ ':scrWidth div 2 + 14);
                    writeln(' \ \        / /_   _| \ | |':scrWidth div 2 + 14);
                    writeln('  \ \  /\  / /  | | |  \| |':scrWidth div 2 + 14);
                    writeln('   \ \/  \/ /   | | | . ` |':scrWidth div 2 + 14);
                    writeln('    \  /\  /   _| |_| |\  |':scrWidth div 2 + 14);
                    writeln('     \/  \/   |_____|_| \_|':scrWidth div 2 + 14);
                end
                else if g.winner = p2 then
                begin
                    ploseCount := ploseCount + 1;
                    gotoxy(1,scrHeight - 7);
                    writeln('  _      ____   _____ ______ ':scrWidth div 2 + 15);
                    writeln(' | |    / __ \ / ____|  ____|':scrWidth div 2 + 15);
                    writeln(' | |   | |  | | (___ | |__   ':scrWidth div 2 + 15);
                    writeln(' | |   | |  | |\___ \|  __|  ':scrWidth div 2 + 15);
                    writeln(' | |___| |__| |____) | |____ ':scrWidth div 2 + 15);
                    writeln(' |______\____/|_____/|______|':scrWidth div 2 + 15);
                end
                else
                begin
                    pdrawCount := pdrawCount + 1;
                    gotoxy(1,scrHeight - 7);
                    writeln('  _____  _____       __          __':scrWidth div 2 + 18);
                    writeln(' |  __ \|  __ \     /\ \        / /':scrWidth div 2 + 18);
                    writeln(' | |  | | |__) |   /  \ \  /\  / / ':scrWidth div 2 + 18);
                    writeln(' | |  | |  _  /   / /\ \ \/  \/ /  ':scrWidth div 2 + 18);
                    writeln(' | |__| | | \ \  / ____ \  /\  /   ':scrWidth div 2 + 18);
                    writeln(' |_____/|_|  \_\/_/    \_\/  \/    ':scrWidth div 2 + 18);
                end;
                writeln('Enter key to go back':scrWidth div 2 + 10);
                writeln('B key to save this game':scrWidth div 2 + 12);
                saveSave;
                repeat 
                    c := upcase(readkey);
                    if c = 'B' then
                    begin
                        saveGame;
                        gotoxy(1,scrHeight);
                        writeln('Game saved                  ':scrWidth div 2 + 12);
                    end;
                until c = #13;
            end
            else
            begin {vs human}
                vsHuman := true;
                initGame(g);
                writeTicTacToePlayScreen;
                repeat 
                    writeTurnMarker(g.playTurn);
                    x := lx;
                    y := ly;
                    writeTicTacToePlayBtn(x,y,false,g.board[x,y]=null,g.playTurn);
                    repeat
                        c := upcase(readkey);
                        writeTicTacToePlayBtn(x,y,true,false,g.board[x,y]);
                        {if c = #0 then c := readkey;}
                        if c = 'W' then
                        begin
                            if y > 1 then
                                y := y - 1;
                        end
                        else if c = 'S' then
                        begin
                            if y < boardSize then
                                y := y + 1;
                        end
                        else if c = 'A' then
                        begin
                            if x > 1 then
                                x := x - 1;
                        end
                        else if c = 'D' then
                        begin
                            if x < boardSize then
                                x := x + 1;
                        end
                        else if c = 'R' then
                        begin
                            gotoxy(1,scrHeight - 3);
                            textcolor(yellow);
                            textbackground(red);
                            write('   Confirm resign? (Y/N) ');
                            if upcase(readkey) = 'Y' then
                            begin
                                g.gameOver := true;
                                g.winner := p2;
                            end
                            else
                            begin
                                gotoxy(1,scrHeight - 3);
                                textbackground(green);
                                write('':25);
                                gotoxy(1,scrHeight - 3);
                                textcolor(yellow);
                                textbackground(red);
                                write('   Resign (R) ');
                            end;
                        end;
                        writeTicTacToePlayBtn(x,y,false,g.board[x,y]=null,g.playTurn);
                    until (c = 'F') and (g.board[x,y] = null) or g.gameOver;
                    lx := x;
                    ly := y;
                    if not g.gameOver then
                    begin
                        writeTicTacToePlayBtn(x,y,true,false,g.playTurn);
                        move(g,x,y);
                        if not g.gameOver then
                        begin
                            writeTurnMarker(g.playTurn);
                            x := lx2;
                            y := ly2;
                            writeTicTacToePlayBtn(x,y,false,g.board[x,y]=null,g.playTurn);
                            repeat
                                c := upcase(readkey);
                                writeTicTacToePlayBtn(x,y,true,false,g.board[x,y]);
                                if c = #0 then c := upcase(readkey);
                                if c = #72 then
                                begin
                                    if y > 1 then
                                        y := y - 1;
                                end
                                else if c = #80 then
                                begin
                                    if y < boardSize then
                                        y := y + 1;
                                end
                                else if c = #75 then
                                begin
                                    if x > 1 then
                                        x := x - 1;
                                end
                                else if c = #77 then
                                begin
                                    if x < boardSize then
                                        x := x + 1;
                                end
                                else if c = 'L' then
                                begin
                                    gotoxy(scrWidth - 24,scrHeight - 3);
                                    textcolor(yellow);
                                    textbackground(red);
                                    write(' Confirm resign? (Y/N)   ');
                                    if upcase(readkey) = 'Y' then
                                    begin
                                        g.gameOver := true;
                                        g.winner := p1;
                                    end
                                    else
                                    begin
                                        gotoxy(scrWidth - 24,scrHeight - 3);
                                        textbackground(green);
                                        write('':25);
                                        gotoxy(scrWidth - 13,scrHeight - 3);
                                        textcolor(yellow);
                                        textbackground(red);
                                        write(' Resign (L)   ');
                                    end;
                                end;
                                writeTicTacToePlayBtn(x,y,false,g.board[x,y]=null,g.playTurn);
                            until (c = #13) and (g.board[x,y] = null) or g.gameOver;
                            lx2 := x;
                            ly2 := y;
                            if not g.gameOver then 
                            begin
                                writeTicTacToePlayBtn(x,y,true,false,g.playTurn);
                                move(g,x,y);
                            end;
                        end;
                    end;
                until g.gameOver;
                textcolor(black);
                textbackground(green);
                if g.winner = p1 then
                begin
                    p1winCount := p1winCount + 1;
                    gotoxy(1,scrHeight - 7);
                    writeln(' __          _______ _   _ ','':scrWidth - 28);
                    writeln(' \ \        / /_   _| \ | |','':scrWidth - 28);
                    writeln('  \ \  /\  / /  | | |  \| |','':scrWidth - 28);
                    writeln('   \ \/  \/ /   | | | . ` |','':scrWidth - 28);
                    writeln('    \  /\  /   _| |_| |\  |','':scrWidth - 28);
                    writeln('     \/  \/   |_____|_| \_|','':scrWidth - 28);
                end
                else if g.winner = p2 then
                begin
                    p2winCount := p2winCount + 1;
                    gotoxy(1,scrHeight - 7);
                    writeln(' __          _______ _   _ ':scrWidth-1);
                    writeln(' \ \        / /_   _| \ | |':scrWidth-1);
                    writeln('  \ \  /\  / /  | | |  \| |':scrWidth-1);
                    writeln('   \ \/  \/ /   | | | . ` |':scrWidth-1);
                    writeln('    \  /\  /   _| |_| |\  |':scrWidth-1);
                    writeln('     \/  \/   |_____|_| \_|':scrWidth-1);
                end
                else
                begin
                    p2drawCount := p2drawCount + 1;
                    gotoxy(1,scrHeight - 7);
                    writeln('  _____  _____       __          __':scrWidth div 2 + 18,'':scrWidth div 2 - 19);
                    writeln(' |  __ \|  __ \     /\ \        / /':scrWidth div 2 + 18,'':scrWidth div 2 - 19);
                    writeln(' | |  | | |__) |   /  \ \  /\  / / ':scrWidth div 2 + 18,'':scrWidth div 2 - 19);
                    writeln(' | |  | |  _  /   / /\ \ \/  \/ /  ':scrWidth div 2 + 18,'':scrWidth div 2 - 19);
                    writeln(' | |__| | | \ \  / ____ \  /\  /   ':scrWidth div 2 + 18,'':scrWidth div 2 - 19);
                    writeln(' |_____/|_|  \_\/_/    \_\/  \/    ':scrWidth div 2 + 18,'':scrWidth div 2 - 19);
                end;
                writeln('Enter key to go back':scrWidth div 2 + 10);
                writeln('B key to save this game':scrWidth div 2 + 12);
                saveSave;
                repeat 
                    c := upcase(readkey);
                    if c = 'B' then
                    begin
                        saveGame;
                        gotoxy(1,scrHeight);
                        writeln('Game saved                  ':scrWidth div 2 + 12);
                    end;
                until c = #13;
            end;
        end
        else if selection = 2 then {stats}
        begin
            writeStatsScreen;
            repeat 
                c := readkey;
            until c = #13;
        end;
    until selection = 3;
end.
