unit ChatProtocol;

interface

uses
  SyncObjs;

const
  PACK_FLAG = $FFBBFFCC;
  MapLength = 19; //��ͼ��󳤶�
  MapWide = 19; //��ͼ������
  MaxFloatDistance = 4;

const
  CELL_WIDTH = 40; //ÿ������40����
  DEFAULT_SPEED = 2 * CELL_WIDTH;     // Speed Ĭ��speed ÿ��2����λ��
  SPEED_INTERVAL = 20;
  FPS = 16;

type
  MoveDirect = (MOVEUP, MOVEDOWN, MOVELEFT, MOVERIGHT);

  FaceOrientate = (NORTH, SOUTH, WEST, EAST);

  RoleState = (ROLESTILL, ROLEMOVE, ROLEDEAING, ROLEDEAD);

  ItemState = (Origin, Boom, Dispear);

  TUserAccount = array[0..15] of AnsiChar;

  TArrayOfBoomDestroy = array[0..3, 0..1] of Integer;

  PChatMsgHead = ^TChatMsgHead;

  TChatMsgHead = record
    Flag: Cardinal;
    Size: Integer;
    Command: Integer;
    Param: Integer;
  end;

  PChatMsg = ^TChatMsg;

  TChatMsg = record
    Head: TChatMsgHead;
    Data: array[0..0] of Byte;
  end;

  PCMRegister = ^TCMRegister;

  TCMRegister = record
    Head: TChatMsgHead;
//    Account: TUserAccount;
    UserName: TUserAccount;
    Password: array[0..15] of AnsiChar;
  end;

  PCMLogin = ^TCMLogin;

  TCMLogin = record
    Head: TChatMsgHead;
    UserName: TUserAccount;
    Password: array[0..15] of AnsiChar;
  end;

  PCMUserState = ^TCMUserState;

  TCMUserState = record
    Head: TChatMsgHead;
  end;

  PTCMap = ^TCMap;

  TCMap = record
    Head: TChatMsgHead;
  end;

  PTSMap = ^TSMap;

  TSMap = record
    Head: TChatMsgHead;
    Map: array[0..MapLength, 0..MapWide] of Integer;
  end;

  PPlayerMove = ^TPlayerMove;

  TPlayerMove = record
    head: TChatMsgHead;
    PlayerName: TUserAccount;
    MoveType: MoveDirect;
  end;

  TPlayerStopMove = record
    head: TChatMsgHead;
    PlayerName: TUserAccount;
  end;

  PSMUserState = ^TSMUserState;

  TSMUserState = record
    Head: TChatMsgHead;
    Online: Boolean;
    Account: TUserAccount;
  end;

  PCMChitChat = ^TCMChitChat;

  TCMChitChat = record
    Head: TChatMsgHead;
    DestAccount: TUserAccount;
    Msg: array[0..255] of AnsiChar;
  end;

  PSMChitChat = ^TSMChitChat;

  TSMChitChat = record
    Head: TChatMsgHead;
    SrcAccount: TUserAccount;
    Msg: array[0..255] of AnsiChar;
  end;

  PServerMessage = ^TServerMessage;

  TServerMessage = record
    Head: TChatMsgHead;
    ErrorCode: Integer;
    ErrorInfo: array[0..31] of AnsiChar;
  end;

  PTPlayerInfo = ^TPlayerInfo;

  TPlayerInfo = record
    Head: TChatMsgHead;
    UserID: Integer;
    UserName: array[0..15] of AnsiChar;
    UserPosX: Integer;
    UserPosY: Integer;
    FaceTo: FaceOrientate;
    Speed: Integer;
  end;

  TUserList = array[0..4] of TPlayerInfo;

  PTPlayerInfoList = ^TPlayerInfoList;

  TPlayerInfoList = record
    head: TChatMsgHead;
    UserList: TUserList; //array[0..4] of TPlayerInfo;
  end;

 // ��ͼ Ϊ��ά����
  MapSign = (PMOVE, PBLOCK, PBOX, PCHARACTRT, PBOMB, PSHOES, PBOT); //0 ���ƶ���1 ���ɣ�2 ľ�䣬3�н�ɫ��4ը��, 5Ь��

  TPlayerSetBoom = record
    head: TChatMsgHead;
    PlayerName: TUserAccount; //�����û���Ѱ������
  end;

  PTShoesInfo = ^TShoesInfo;

  TShoesInfo = record      //Ь�ӵ�����Ϣ
    head: TChatMsgHead;
    ShoesPosX: Integer;
    ShoesPosY: Integer;
  end;

  PTBombSeted = ^TBombSeted;

  TBombSeted = record   //���������ú�ը������ը�����귢���ͻ���
    head: TChatMsgHead;
    BombPosX: Integer;
    BombPosY: Integer;
  end;

  PTBombBoom = ^TBombBoom;

  TBombBoom = record  //ը����ը�����ͷ�Χ�Լ��ݻ�ľ������
    head: TChatMsgHead;
    Bombx: Integer;
    BombY: Integer;
    BoomW: Integer;
    BoomA: Integer;
    BoomS: Integer;
    BoomD: Integer;
    DestoryPos: TArrayOfBoomDestroy;
  end;

  PTBoomFirePic = ^TBoomFirePic;

  TBoomFirePic = record
    Next: PTBoomFirePic;
    BombX: Integer;
    BombY: Integer;
    BoomW: Integer;
    BoomA: Integer;
    BoomS: Integer;
    BoomD: Integer;
    Tick: Integer;
  end;

  PTOneMove = ^TOneMove;

  TOneMove = record
    Next: PTOneMove;
    UserId: Integer;
    SrcX: Integer;
    SrcY: Integer;
    DesX: Integer;
    DesY: Integer;
    FaceTo: FaceOrientate;
    Tick: Integer;
  end;

  PTRoleMove = ^TRoleMove;

  TRoleMove = record
    Next: PTRoleMove;
    TurnTo: FaceOrientate;
    Speed: Integer;
    DesX: Integer;
    DesY: Integer;
  end;

  PTBoomPic = ^TBoomPic;

  TBoomPic = record
    Next: PTBoomPic;
    PosX: Integer;
    PosY: Integer;
    Tick: Integer;
  end;

  PTPlayerDeadEvent = ^TPlayerDeadEvent;

  TPlayerDeadEvent = record   //��ը�������Ϣ
    Head: TChatMsgHead;
    UserName: array[0..15] of AnsiChar;
    PlayerPosX: Integer;
    PlayerPosY: Integer;
  end;

  PTPlayerDead = ^TPlayerDead;

  TPlayerDead = record
    Next: PTPlayerDead;
    PlayerPosX: Integer;
    PlayerPosY: Integer;
    PlayerId: Integer;
    PlayerName: TUserAccount;
    Tick: Integer;
  end;

  PTBot = ^TBot;

  TBot = record
    Head: TChatMsgHead;
    RoBotID: Integer;
    BotPosX: Integer;
    BotPosY: Integer;
    BotFaceTo: FaceOrientate;
  end;

   TBots = record
    RoBotID: Integer;
    BotPosX: Integer;
    BotPosY: Integer;
    BotFaceTo: FaceOrientate;
  end;

  TReqbotlist = record
    head: TChatMsgHead;
  end;

  PTRoBotInfoList = ^TRoBotInfoList;
  TRoBotInfoList = record
    head: TChatMsgHead;
    BotNums: Integer;
    BotList: array[0..4] of TBots;
  end;

type
  PChatMsgNode = ^TChatMsgNode;

  TChatMsgNode = record
    Next: PChatMsgNode;
    ChatMsgPtr: PChatMsg;
  end;

  TChatMsgs = class
  protected
    FHeadPtr: PChatMsgNode;
    FTailPtr: PChatMsgNode;
  protected
    procedure AddNodeLinkToTail(HeadPtr, TailPtr: PChatMsgNode); virtual;
  public
    procedure FetchNext(var MsgPtr: PChatMsg); virtual;
    procedure AddTail(ChatMsgPtr: PChatMsg); virtual;
    procedure FetchTo(Dest: TChatMsgs); virtual;
    function IsEmpty: Boolean; virtual;
    function MsgNum: Integer;
    procedure Clear; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TLockChatMsgs = class(TChatMsgs)
  private
    FLock: TCriticalSection;
  protected
    procedure AddNodeLinkToTail(HeadPtr, TailPtr: PChatMsgNode); override;
  public
    procedure FetchNext(var MsgPtr: PChatMsg); override;
    procedure AddTail(ChatMsgPtr: PChatMsg); override;
    procedure FetchTo(Dest: TChatMsgs); override;
    procedure Clear; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

const
  C_REGISTER = 1;
  S_REGISTER = 2;
  C_LOGIN = 3;
  S_LOGIN = 4;
  C_MAP = 5;
  S_MAP = 6;
  C_MOVE = 7;
  S_PLAYERMOVE = 8;
  S_PlayerInfo = 9;
  C_BOOM = 10;
  S_SETBOME = 11;
  S_BOMBBOOM = 12;
  S_PLAYERDEAD = 13;
  S_USERLIST = 14;
  S_USERLEAVE = 15;
  S_PLAYERLEAVE = 16;
  S_SETSHOES = 17;
  C_USEPROP = 18;
  S_RANGEDPROP = 19;
  S_BOTINFO = 20;
  S_BOTMOVE = 21;
  C_STOPMOVE = 22;
  C_GETBOTINFO = 23;
  C_REQBOTlIST = 24;
  S_BOTLIST = 25;

implementation

{ TChatMsgs }

procedure TChatMsgs.AddNodeLinkToTail(HeadPtr, TailPtr: PChatMsgNode);
begin
  if FHeadPtr <> nil then
  begin
    FTailPtr^.Next := HeadPtr;
    FTailPtr := TailPtr;
  end
  else
  begin
    FHeadPtr := HeadPtr;
    FTailPtr := TailPtr;
  end;
end;

procedure TChatMsgs.AddTail(ChatMsgPtr: PChatMsg);
var
  NewNodePtr: PChatMsgNode;
begin
  NewNodePtr := AllocMem(SizeOf(PChatMsgNode));
  NewNodePtr^.ChatMsgPtr := ChatMsgPtr;

  if FHeadPtr = nil then
  begin
    FHeadPtr := NewNodePtr;
    FTailPtr := FHeadPtr;
  end
  else
  begin
    FTailPtr^.Next := NewNodePtr;
    FTailPtr := NewNodePtr;
  end;
end;

procedure TChatMsgs.FetchTo(Dest: TChatMsgs);
begin
  if FTailPtr <> nil then
  begin
    Dest.AddNodeLinkToTail(FHeadPtr, FTailPtr);

    FHeadPtr := nil;
    FTailPtr := nil;
  end;
end;

procedure TChatMsgs.Clear;
var
  LinkPtr, OldPtr: PChatMsgNode;
begin
  LinkPtr := FHeadPtr;
  FHeadPtr := nil;
  FTailPtr := nil;

  while LinkPtr <> nil do
  begin
    OldPtr := LinkPtr;
    LinkPtr := LinkPtr^.Next;

    FreeMem(OldPtr^.ChatMsgPtr);
    FreeMem(OldPtr);
  end;
end;

constructor TChatMsgs.Create;
begin

end;

destructor TChatMsgs.Destroy;
begin
  Clear;

  inherited;
end;

procedure TChatMsgs.FetchNext(var MsgPtr: PChatMsg);
var
  FetchNodePtr: PChatMsgNode;
begin
  MsgPtr := nil;
  if FHeadPtr <> nil then
  begin
    FetchNodePtr := FHeadPtr;
    FHeadPtr := FHeadPtr^.Next;
    if FHeadPtr = nil then
      FTailPtr := nil;

    MsgPtr := FetchNodePtr^.ChatMsgPtr;

    FreeMem(FetchNodePtr);
  end;
end;

function TChatMsgs.IsEmpty: Boolean;
begin
  Result := (FHeadPtr = nil);
end;

function TChatMsgs.MsgNum: Integer;
var
  num: Integer;
  Ptr: PChatMsgNode;
begin
//
  Result := 0;
  num := 0;
  Ptr := FHeadPtr;
  while Ptr <> nil do
  begin
    Inc(num);
    Ptr := Ptr.Next;
  end;
  Result := num;
end;

{ TLockChatMsgs }

procedure TLockChatMsgs.AddNodeLinkToTail(HeadPtr, TailPtr: PChatMsgNode);
begin
  FLock.Enter;
  try
    inherited;
  finally
    FLock.Leave;
  end;
end;

procedure TLockChatMsgs.AddTail(ChatMsgPtr: PChatMsg);
begin
  FLock.Enter;
  try
    inherited;
  finally
    FLock.Leave;
  end;
end;

procedure TLockChatMsgs.FetchTo(Dest: TChatMsgs);
begin
  FLock.Enter;
  try
    inherited;
  finally
    FLock.Leave;
  end;
end;

procedure TLockChatMsgs.Clear;
begin
  FLock.Enter;
  try
    inherited;
  finally
    FLock.Leave;
  end;
end;

constructor TLockChatMsgs.Create;
begin
  inherited;
  FLock := TCriticalSection.Create;
end;

destructor TLockChatMsgs.Destroy;
begin
  FLock.Enter;
  try
    inherited;
  finally
    FLock.Leave;
  end;

  FLock.Free;
end;

procedure TLockChatMsgs.FetchNext(var MsgPtr: PChatMsg);
var
  FetchNodePtr: PChatMsgNode;
begin
  MsgPtr := nil;

  FLock.Enter;
  try
    FetchNodePtr := FHeadPtr;
    if FHeadPtr <> nil then
    begin
      FHeadPtr := FHeadPtr^.Next;
      if FHeadPtr = nil then
        FTailPtr := nil;
    end;
  finally
    FLock.Leave;
  end;

  if FetchNodePtr <> nil then
  begin
    MsgPtr := FetchNodePtr^.ChatMsgPtr;
    FreeMem(FetchNodePtr);
  end;
end;

end.
