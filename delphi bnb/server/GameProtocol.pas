unit GameProtocol;

interface

uses
  System.SyncObjs, System.SysUtils, System.Classes, Winapi.Windows;

const
  PACK_FLAG = $FFBBFFCC;
  MapLength = 19;
  MapWide = 19;
  BoomTime = 5000;
  BoomScope = 5;

type
  MoveDirect = (MOVEUP, MOVEDOWN, MOVELEFT, MOVERIGHT);

  FaceOrientate = (NORTH, SOUTH, WEST, EAST);

  DestoryTypes = (NoDestory, Block, Box, Player, Bomb);

  PGameMsgHead = ^TGameMsgHead;

  TGameMsgHead = record
    Flag: Cardinal;
    Size: Integer;
    Command: Integer;
    Param: Integer;
  end;

  PLoginMsg = ^TLoginMsg;

  TLoginMsg = record
    Head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
    Password: array[0..15] of AnsiChar;
  end;

  PServerMessage = ^TServerMessage;

  TServerMessage = record
    head: TGameMsgHead;
    ErrorCode: Integer;
    ErrorInfo: array[0..31] of AnsiChar;
  end;

  TRangedPropInfo = record  //远程武器摧毁信息
    head: TGameMsgHead;
    DestoryType: DestoryTypes;
    DestoryPosX: Integer;
    DestoryPosY: Integer;
  end;

  MapSign = (PMOVE, PBLOCK, PBOX, PCHARACTRT, PBOMB, PSHOES, PBOT); //可移动，障碍物，木箱，有角色，炸弹，鞋子

  PropTypes = (NoProp, MeleeWeapon, RangedWeapon); //无武器，近身武器，远程武器

  FindPathState = (NOSTATE, NOPATH, HAVEPATH);

  TMap = record
    head: TGameMsgHead;
    Map: array[0..MapLength, 0..MapWide] of Integer;
  end;

  TPlayerInfo = record
    head: TGameMsgHead;
    UserID: Integer;
    UserName: array[0..15] of AnsiChar;
    UserPosX: Integer;
    UserPosY: Integer;
    FaceTo: FaceOrientate;
    Speed: Integer;
  end;

  TPlayerInfoList = record
    head: TGameMsgHead;
    UserList: array[0..4] of TPlayerInfo;
  end;

  PPlayerMove = ^TPlayerMove;

  TPlayerMove = record  //客户端发给服务器的移动消息
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
    MoveType: MoveDirect;
  end;

  PPlayerStopMove = ^TPlayerStopMove;

  TPlayerStopMove = record
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
  end;

  PPlayerSetBoom = ^TPlayerSetBoom;

  TPlayerSetBoom = record     //客户端发给服务器的放置炸弹消息
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar; //根据用户名寻找坐标
  end;

  TBombSeted = record   //服务器放置好炸弹，将炸弹坐标发给客户端
    head: TGameMsgHead;
    BombPosX: Integer;
    BombPosY: Integer;
  end;

  TBombBoom = record  //炸弹爆炸，发送范围以及摧毁木箱坐标
    head: TGameMsgHead;
    Bombx: Integer;
    BombY: Integer;
    BoomW: Integer;
    BoomA: Integer;
    BoomS: Integer;
    BoomD: Integer;
    DestoryPos: array[0..3, 0..1] of Integer;
  end;

  TPlayerDeadEvent = record   //被炸死玩家信息
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
    PlayerPosX: Integer;
    PlayerPosY: Integer;
  end;

  TShoesInfo = record      //鞋子道具信息
    head: TGameMsgHead;
    ShoesPosX: Integer;
    ShoesPosY: Integer;
  end;

  TPlayerLeave = record    //玩家离开信息
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
  end;

  PUseProp = ^TUseProp;

  TUseProp = record   //玩家使用道具
    head: TGameMsgHead;
    PropType: PropTypes;
    UserName: array[0..15] of AnsiChar;
    FaceTo: FaceOrientate;
  end;

  TBomb = class
  public
    BombID: Integer;
    Timer: Int64;
  private
    BombPosX: Integer;
    BombPosY: Integer;
  public
    constructor Create(x: Integer; y: Integer);
    property FBombPosX: Integer read BombPosX;
    property FBombPosY: Integer read BombPosY;
  end;

  TMovePlayer = class
  public
    UserName: AnsiString;
    Timer: Int64;
    MoveType: MoveDirect;
    MoveSpeed: Integer;
  end;

  TBots = record
    RoBotID: Integer;
    BotPosX: Integer;
    BotPosY: Integer;
    BotFaceTo: Integer;
  end;

  TRoBotInfoList = record
    head: TGameMsgHead;
    BotNums: Integer;
    BotList: array[0..4] of TBots;
  end;

  TBotInfo = record
    head: TGameMsgHead;
    BotID: Integer;
    BotPosX: Integer;
    BotPosY: Integer;
    BotFaceTo: Integer;
  end;

  TFindUserPos = record
    FindPosX: Integer;
    FindPosY: Integer;
  end;

  TReqbotlist = record
    head: TGameMsgHead;
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

{ TBOMB }

{ TBOMB }

constructor TBOMB.Create(x, y: Integer);
begin
  Timer := GetTickCount;
  BombPosX := x;
  BombPosY := y;
end;

end.

