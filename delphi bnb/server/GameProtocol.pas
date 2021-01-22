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

  TRangedPropInfo = record  //Զ�������ݻ���Ϣ
    head: TGameMsgHead;
    DestoryType: DestoryTypes;
    DestoryPosX: Integer;
    DestoryPosY: Integer;
  end;

  MapSign = (PMOVE, PBLOCK, PBOX, PCHARACTRT, PBOMB, PSHOES, PBOT); //���ƶ����ϰ��ľ�䣬�н�ɫ��ը����Ь��

  PropTypes = (NoProp, MeleeWeapon, RangedWeapon); //������������������Զ������

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

  TPlayerMove = record  //�ͻ��˷������������ƶ���Ϣ
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

  TPlayerSetBoom = record     //�ͻ��˷����������ķ���ը����Ϣ
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar; //�����û���Ѱ������
  end;

  TBombSeted = record   //���������ú�ը������ը�����귢���ͻ���
    head: TGameMsgHead;
    BombPosX: Integer;
    BombPosY: Integer;
  end;

  TBombBoom = record  //ը����ը�����ͷ�Χ�Լ��ݻ�ľ������
    head: TGameMsgHead;
    Bombx: Integer;
    BombY: Integer;
    BoomW: Integer;
    BoomA: Integer;
    BoomS: Integer;
    BoomD: Integer;
    DestoryPos: array[0..3, 0..1] of Integer;
  end;

  TPlayerDeadEvent = record   //��ը�������Ϣ
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
    PlayerPosX: Integer;
    PlayerPosY: Integer;
  end;

  TShoesInfo = record      //Ь�ӵ�����Ϣ
    head: TGameMsgHead;
    ShoesPosX: Integer;
    ShoesPosY: Integer;
  end;

  TPlayerLeave = record    //����뿪��Ϣ
    head: TGameMsgHead;
    UserName: array[0..15] of AnsiChar;
  end;

  PUseProp = ^TUseProp;

  TUseProp = record   //���ʹ�õ���
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
