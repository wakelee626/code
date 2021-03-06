unit FormLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ChatProtocol;

type
  TWorkState = (osNone, osRequestRegister, osRequestLogin, osWaitRegister, osWaitLogin);

  TFrmLogin = class(TForm)
    Label1: TLabel;
    edtAccount: TEdit;
    Label2: TLabel;
    edtPassword: TEdit;
    Label3: TLabel;
    cbbServerIP: TComboBox;
    btnLogin: TButton;
    btnRegister: TButton;
    btnCancel: TButton;
    Timer1: TTimer;
    pbWait: TPaintBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRegisterClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pbWaitPaint(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    FWorkState: TWorkState;
    FStateTime: TDateTime;

    FMsgs: TChatMsgs;
  private
    procedure ChangeWorkState(NewState: TWorkState);

  private
    procedure StopWait;
    procedure ProcessServerMsgs;
    procedure DoWork;
  private
    { Private declarations }
    procedure EnableUI(Enable: Boolean);
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

uses
  ChatManager, TCPClient, DateUtils;

{$R *.dfm}

procedure TFrmLogin.btnLoginClick(Sender: TObject);
begin
  FWorkState := osRequestLogin;

  EnableUI(False);

  ChatMgr.Host := cbbServerIP.Text;
  ChatMgr.Port := 1234;

  ChatMgr.Connect;

  Timer1.Enabled := True;
end;

procedure TFrmLogin.btnRegisterClick(Sender: TObject);
begin
  FWorkState := osRequestRegister;

  EnableUI(False);

  ChatMgr.Host := cbbServerIP.Text;
//  ChatMgr.Port := 7622;
  ChatMgr.Port := 1234;
  ChatMgr.Connect;

  Timer1.Enabled := True;
end;

procedure TFrmLogin.ChangeWorkState(NewState: TWorkState);
begin
  if FWorkState <> NewState then
  begin
    FStateTime := Now;
    FWorkState := NewState;
  end;
end;

procedure TFrmLogin.DoWork;
begin
  ProcessServerMsgs;

  case FWorkState of
    osRequestRegister:
    begin
      pbWait.Invalidate;
      case ChatMgr.Status of
        CS_CONNECTFAILED: StopWait;

        CS_RUNNING:
        begin
          ChatMgr.RequestRegister(edtAccount.Text, edtPassword.Text);
          ChangeWorkState(osWaitRegister);
        end;
      end;
    end;

    osRequestLogin:
    begin
      pbWait.Invalidate;
      case ChatMgr.Status of
        CS_CONNECTFAILED: StopWait;

        CS_RUNNING:
        begin
          ChatMgr.RequestLogin(edtAccount.Text, edtPassword.Text);
          ChangeWorkState(osWaitRegister);
        end;
      end;
    end;

    osWaitRegister:
    begin
      pbWait.Visible := True;
      pbWait.Invalidate;
      if SecondSpan(Now, FStateTime) > 15 then
      begin
        ChatMgr.Disconnect;
        ChangeWorkState(osNone);
        Timer1.Enabled := False;
        FMsgs.Clear;

        EnableUI(True);
      end;
    end;

    osWaitLogin:
    begin
      pbWait.Visible := True;
      pbWait.Invalidate;
    end;
  end;
end;

procedure TFrmLogin.EnableUI(Enable: Boolean);
begin
  edtAccount.Enabled := Enable;
  edtPassword.Enabled := Enable;
  cbbServerIP.Enabled := Enable;
  btnLogin.Enabled := Enable;
  btnRegister.Enabled := Enable;
  btnCancel.Enabled := Enable;

  if Enable then
  begin
    edtAccount.Color := clWindow;
    edtPassword.Color := clWindow;
    cbbServerIP.Color := clWindow;
  end
  else
  begin
    edtAccount.Color := clBtnFace;
    edtPassword.Color := clBtnFace;
    cbbServerIP.Color := clBtnFace;
  end;

  pbWait.Visible := not Enable;
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  FMsgs := TChatMsgs.Create;
end;

procedure TFrmLogin.FormDestroy(Sender: TObject);
begin
  FMsgs.Free;
end;

procedure TFrmLogin.pbWaitPaint(Sender: TObject);
var
  MaxV: Int64;
  i: Integer;
begin
  if pbWait.Visible then
  begin
    MaxV := Round(Now * 24 * 3600 * 4);

    MaxV := MaxV mod 20;
    case FWorkState of
      osWaitRegister: pbWait.Canvas.Brush.Color := clGreen;
      osWaitLogin: pbWait.Canvas.Brush.Color := clBlue;
      else
        pbWait.Canvas.Brush.Color := clRed;
    end;

    for i := 0 to MaxV do
      pbWait.Canvas.FillRect(Rect(0 + i * 10, 0, 6 + i * 10, 6));
  end;
end;

procedure TFrmLogin.ProcessServerMsgs;
var
  MsgPtr: PChatMsg;
  ServerMsgPtr: PServerMessage;
  PlayerPtr: PTPlayerInfo;
  Ptr: PByte;
begin
  ChatMgr.ReadResponse(FMsgs);
  while not FMsgs.IsEmpty do
  begin
    FMsgs.FetchNext(MsgPtr);

    if MsgPtr <> nil then
    begin
      ServerMsgPtr := PServerMessage(MsgPtr);
      try
        case ServerMsgPtr^.Head.Command of
          S_REGISTER:
          begin
            StopWait;
            ChatMgr.Disconnect;

            if ServerMsgPtr^.ErrorCode = 0 then
              MessageDlg('ע��ɹ�, �������ʻ������½!', mtInformation, [mbOK], 0)
            else
              MessageDlg('ע��ʧ��', mtError, [mbOK], 0);

          end;

          S_LOGIN:
          begin
            StopWait;

            if ServerMsgPtr^.ErrorCode <> 0 then
            begin
              ChatMgr.Disconnect;
              MessageDlg('��½ʧ�� : ' + String(ServerMsgPtr^.ErrorInfo), mtError, [mbOK], 0);
            end
            else
            begin
              ModalResult := mrOK;
//              OutputDebugString('login success');
              Timer1.Enabled := False;
//              Ptr := Pointer(Integer(MsgPtr) + ServerMsgPtr^.Head.Size);
//              PlayerPtr :=  PTPlayerInfo(Ptr);
//                Exit;
            end;
//           break;
          end;
         S_PlayerInfo:
            begin
//              UserPtr := PTPlayerInfo(MsgPtr);
//              AddUserToList(UserPtr);
//                OutputDebugString('recv playerinfo');
                PlayerPtr := PTPlayerInfo(MsgPtr);
                ChatMgr.WirtePlayerInfo(PlayerPtr);
            end;

        end;
      finally
        FreeMem(MsgPtr);
      end;
    end;
  end;
end;

procedure TFrmLogin.StopWait;
begin
  ChangeWorkState(osNone);
  Timer1.Enabled := False;
//  FMsgs.Clear;

  EnableUI(True);
  ChatMgr.Reset;
end;

procedure TFrmLogin.Timer1Timer(Sender: TObject);
begin
  DoWork;
end;

end.
