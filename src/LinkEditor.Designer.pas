unit LinkEditor.Designer;

interface
{
  DelphiTips.LinkEditor (c)2022 by Paul TOTH

  this code is free to use

  proper credits are welcome

  https://github.com/tothpaul
}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, vcl.GraphUtil;

type
  TDesignTable = class(TCustomPanel)
  private
    FLabel: TLabel;
    FList : TListBox;
    FOrgPos: Tpoint;
    FMousePos: TPoint;
    FTableEnter: TNotifyEvent;
    procedure WMWindowPosChanged(var Msg: TMessage); message WM_WINDOWPOSCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure LabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListEnter(Sender: TObject);
    procedure ListExit(Sender: TObject);
    procedure ListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function ItemRect(Index: Integer): TRect;
  protected
    procedure CreateParams(var Params:TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AddField(const Name: string);
    function FieldCount: Integer;
    property Caption;
  end;

  TDesignLink = class;

  TDesigner = class(TFrame)
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FrameDblClick(Sender: TObject);
  private
    { Déclarations privées }
    FTables: TList;
    FLinks: TList;
    FActiveTable: TDesignTable;
    FOnSelectTable: TNotifyEvent;
    FCanvas:TControlCanvas;
    FCurLink: TDesignLink;
    procedure TableEnter(Sender: TObject);
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure AddLink(Source, Target: TDesignTable; SourceIndex, TargetIndex: Integer);
    procedure SetActiveTable(Table: TDesignTable);
    procedure DeleteLink(Table: TDesignTable; Index: Integer);
    procedure DeleteTable(Table: TDesignTable);
  protected
    procedure PaintWindow(DC:HDC); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddTable(const Caption: string): TDesignTable;
    function TableCount: Integer;
    property ActiveTable: TDesignTable read FActiveTable;
    property OnSelectTable: TNotifyEvent read FOnSelectTable write FOnSelectTable;
  end;

  TDesignLink = class
    A, B, C: TPoint;
    Active: Boolean;
    SourceTable: TDesignTable;
    TargetTable: TDesignTable;
    SourceIndex: Integer;
    TargetIndex: Integer;
    LinkType: Integer;
    procedure Draw(Canvas:TCanvas);
    function Click(x,y: Integer): Boolean;
  end;

implementation

{$R *.dfm}

{ TDesigner }

procedure TDesigner.AddLink(Source, Target: TDesignTable; SourceIndex,
  TargetIndex: Integer);
var
  Link: TDesignLink;
begin
  for var I := 0 to FLinks.Count - 1 do
  begin
    Link := FLinks[I];
    if (Link.SourceTable = Source) and (Link.SourceIndex = SourceIndex)
    and(Link.TargetTable = Target) and (Link.TargetIndex = TargetIndex) then
    begin
      if Link.LinkType and 2 = 0 then
      begin
        Inc(Link.LinkType, 2);
        Invalidate;
      end;
      Exit;
    end;
    if (Link.SourceTable = Target) and (Link.SourceIndex = TargetIndex)
    and(Link.TargetTable = Source) and (Link.TargetIndex = SourceIndex) then
    begin
      if Link.LinkType and 1 = 0 then
      begin
        Inc(Link.LinkType);
        Invalidate;
      end;
      Exit;
    end;
  end;
  Link := TDesignLink.Create;
  Link.SourceTable := Source;
  Link.TargetTable := Target;
  Link.SourceIndex := SourceIndex;
  Link.TargetIndex := TargetIndex;
  Link.LinkType := 2;
  FLinks.Add(Link);
  Invalidate;
end;

function TDesigner.AddTable(const Caption: string): TDesignTable;
begin
  Result := TDesignTable.Create(Self);
  FTables.Add(Result);
  Result.Caption := Caption;
  Result.Left := 30 * FTables.Count;
  Result.Top := 20 * FTables.Count;
  Result.Height := 100;
  Result.Parent := Self;
  Result.FTableEnter := TableEnter;
  TableEnter(Result);
end;

constructor TDesigner.Create(AOwner: TComponent);
begin
  inherited;
  FTables := TList.Create;
  FLinks := TList.Create;
  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
end;

procedure TDesigner.DeleteLink(Table: TDesignTable; Index: Integer);
begin
  for var I := FLinks.Count - 1 downto 0 do
  begin
    var L := TDesignLink(FLinks[I]);
    if L.SourceTable = Table then
    begin
      if L.SourceIndex = Index then
      begin
        L.Free;
        FLinks.Delete(I);
      end;
      if L.SourceIndex > Index then
        Dec(L.SourceIndex);
    end else
    if L.TargetTable = Table then
    begin
      if L.TargetIndex = Index then
      begin
        L.Free;
        FLinks.Delete(I);
      end;
      if L.TargetIndex > Index then
        Dec(L.TargetIndex);
    end;
  end;
  Invalidate;
end;

procedure TDesigner.DeleteTable(Table: TDesignTable);
begin
  for var I := FLinks.Count - 1 downto 0 do
  begin
    var L := TDesignLink(FLinks[I]);
    if (L.SourceTable = Table) or (L.TargetTable = Table) then
    begin
      L.Free;
      FLinks.Delete(I);
    end;
  end;
  if FActiveTable = Table then
    SetActiveTable(nil);
  FTables.Remove(Table);
  Invalidate;
end;

destructor TDesigner.Destroy;
begin
  FLinks.Free;
  FTables.Free;
  FCanvas.Free;
  inherited;
end;

procedure TDesigner.FrameDblClick(Sender: TObject);
begin
  if FCurLink <> nil then
  begin
    FCurLink.LinkType := 1 + Succ(FCurLink.LinkType) mod 3;
    Invalidate;
  end;
end;

procedure TDesigner.FrameMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Link: TDesignLink;
begin
  SetFocus;
  SetActiveTable(nil);

  for i := 0 to FLinks.Count - 1 do
  begin
    Link := TDesignLink(FLinks[i]);
    if Link.Click(x, y) then
    begin
      if FCurLink = Link then
        Exit;
      if FCurLink <> nil then
        FCurLink.Active := False;
      FCurLink := Link;
      FCurLink.Active := True;
      Invalidate;
      Exit;
    end;
  end;
  if FCurLink <> nil then
  begin
    FCurLink.Active := False;
    FCurLink := nil;
    Invalidate;
   end;
end;

procedure TDesigner.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_DELETE then
  begin
    if FCurLink <> nil then
    begin
      FLinks.Remove(FCurLink);
      FreeAndNil(FCurLink);
      Invalidate;
    end;
  end;
end;

procedure TDesigner.PaintWindow(DC: HDC);
var
  i: Integer;
begin
  FCanvas.Lock;
  try
    FCanvas.Handle := DC;
    try
      for i := 0 to FLinks.Count-1 do
        TDesignLink(FLinks[i]).Draw(FCanvas);
    finally
      FCanvas.Handle:=0;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

procedure TDesigner.SetActiveTable(Table: TDesignTable);
begin
  if Table <> FActiveTable then
  begin
    if FActiveTable <> nil then
      FActiveTable.Color := clGray;
    FActiveTable := Table;
    if FActiveTable <> nil then
    begin
      if FCurLink <> nil then
      begin
        FCurLink.Active := False;
        FCurLink := nil;
        Invalidate;
      end;
      FActiveTable.Color := clSkyBlue;
      FActiveTable.BringToFront;
    end;
    if Assigned(FOnSelectTable) then
      FOnSelectTable(Self);
  end;
end;

procedure TDesigner.TableEnter(Sender: TObject);
begin
  SetActiveTable(TDesignTable(Sender));
end;

procedure TDesigner.WMPaint(var Message: TWMPaint);
begin
  ControlState := ControlState + [csCustomPaint];
  inherited;
  ControlState := ControlState - [csCustomPaint];
end;

function TDesigner.TableCount: Integer;
begin
  Result := FTables.Count;
end;

{ TDesignTable }

procedure TDesignTable.AddField(const Name: string);
begin
  FList.Items.Add(Name);
end;

procedure TDesignTable.CMTextChanged(var Message: TMessage);
begin
  inherited;
  FLabel.Caption := Caption;
end;

constructor TDesignTable.Create(AOwner: TComponent);
begin
  inherited;
  ParentBackground := False;
  Color := clSkyBlue;
  ShowCaption := False;

  FLabel := TLabel.Create(Self);
  FLabel.AlignWithMargins := True;
  FLabel.Align := alTop;
  FLabel.Caption := Caption;
  FLabel.Parent := Self;
  FLabel.OnMouseDown := LabelMouseDown;
  FLabel.OnMouseMove := LabelMouseMove;

  FList := TListBox.Create(Self);
  FList.DragMode := TDragMode.dmAutomatic;
  FList.OnDragOver := ListDragOver;
  FList.OnDragDrop := ListDragDrop;
  FList.OnKeyDown := ListKeyDown;
  FList.Align := alClient;
  FList.Parent := Self;
  FList.OnEnter := ListEnter;
  FList.OnExit := ListExit;
end;

procedure TDesignTable.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_SIZEBOX;
end;

function TDesignTable.FieldCount: Integer;
begin
  Result := FList.Count;
end;

function TDesignTable.ItemRect(Index: Integer): TRect;
var
  p: TPoint;
begin
  Result := FList.ItemRect(Index);

  Inc(Result.Left, Left);

  p.Y := +FList.Top;
  p := TDesigner(Parent).ScreenToClient(ClientToScreen(p));
  Result.Offset(0, p.y);

  Result.Width := Width;
end;

procedure TDesignTable.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_DELETE then
  begin
    TDesigner(Parent).DeleteTable(Self);
    Free;
  end;
end;

procedure TDesignTable.LabelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FOrgPos.X := Left;
  FOrgPos.Y := Top;
  FMousePos := Mouse.CursorPos;
  ListEnter(FList);
  SetFocus;
end;

procedure TDesignTable.LabelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Cursor: TPoint;
  LLeft,LTop,LScroll: Integer;
begin
  if ssLeft in Shift then
  begin
    Cursor := Mouse.CursorPos;
    LScroll := -TScrollingWinControl(Parent).HorzScrollBar.Position;
    LLeft := FOrgPos.X + Cursor.x - FMousePos.x;
    if LLeft < LScroll then
      LLeft := LScroll;
    LScroll := -TScrollingWinControl(Parent).VertScrollBar.Position;
    LTop := FOrgPos.Y + Cursor.y - FMousePos.y;
    if LTop < LScroll then LTop := LScroll;
    SetBounds(LLeft, LTop, Width, Height);
  end;
end;

procedure TDesignTable.ListDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  TDesigner(Parent).AddLink(TListBox(Source).Parent as TDesignTable, Self, TListBox(Source).ItemIndex, FList.ItemIndex);
  TListBox(Source).ItemIndex:=-1;
  FList.ItemIndex := -1;
end;

procedure TDesignTable.ListDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  Item: Integer;
begin
  Accept := False;
  if (Source = Sender) then
    Exit;
  if not (Source is TListBox) then
    Exit;
  if not (TListBox(Source).Parent is TDesignTable) then
    Exit;
  Item := FList.ItemAtPos(Point(X, Y), True);
  if Item < 0 then
    Exit;
  FList.ItemIndex := Item;
  Accept := True;
end;

procedure TDesignTable.ListEnter(Sender: TObject);
begin
  if Assigned(FTableEnter) then
    FTableEnter(Self);
end;

procedure TDesignTable.ListExit(Sender: TObject);
begin
  FList.ItemIndex := -1;
end;

procedure TDesignTable.ListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  var Index := FList.ItemIndex;
  if Index < 0 then
    Exit;
  TDesigner(Parent).DeleteLink(Self, Index);
  FList.Items.Delete(Index);
end;

procedure TDesignTable.WMWindowPosChanged(var Msg: TMessage);
begin
  inherited;
  TDesigner(Parent).Invalidate;
end;

{ TDesignLink }

function TDesignLink.Click(x, y: Integer): Boolean;
const
  k = 4;

  function Between(a,b,c: Integer): Boolean;
  begin
    if b > c then
      Result := Between(a, c, b)
    else
      Result := (a > b - k) and (a < c + k);
  end;

begin
  Result := True;
  if (Abs(y - A.y) < k) and Between(x, A.x, C.x) then
    Exit;
  if (Abs(x - C.x) < k) and Between(y, A.y, B.y) then
    Exit;
  if (Abs(y - B.y) < k) and Between(x, C.x, B.x) then
    Exit;
  Result := False;
end;

procedure TDesignLink.Draw(Canvas: TCanvas);
const
  k = 4;
var
 s,t: TRect;
 D: TPoint;
 Quad: Boolean;
 delta: Integer;
 Arrow1: array[0..2] of TPoint;
 Arrow2: array[0..2] of TPoint;
begin
  Quad := False;
  s := SourceTable.ItemRect(SourceIndex);
  t := TargetTable.ItemRect(TargetIndex);
  if s.Right < t.Left - 6 * k then
  begin
    A.x := s.Right;
    B.x := t.Left;
  end else begin
    if t.Right > s.Left - 6 * k then
    begin
      Quad := True;
      if Abs(s.Left - t.Left) < Abs(s.Right - t.Right) then
      begin
        A.x := s.Left;
        B.x := t.Left;
        if s.Left < t.Left then
          C.x := s.Left - 6 * k
        else
          C.x := t.Left - 6 * k;
      end else begin
        A.x := s.Right;
        B.x := t.Right;
        if s.Right > t.Right then
          C.x := s.Right + 6 * k
        else
          C.x := t.Right + 6 * k;
      end;
    end else begin
      A.x := s.Left;
      B.x := t.Right;
    end;
  end;
  A.y := (s.Top+s.Bottom) div 2;
  B.Y := (t.Top+t.Bottom) div 2;
  if not Quad then
  begin
   C.x := (A.x + B.x) div 2;
  end;
  C.y := (A.y + B.y) div 2;

  D := A;
  if (D.x < C.x) then
    delta := k
  else
    delta := - k;
  Arrow1[0] := D;
  Inc(D.x, 2 * delta);
  Dec(D.y, k);
  Arrow1[1] := D;
  Inc(D.y, 2 * k);
  Arrow1[2] := D;

  D := B;
  if (D.x < C.x) then
    delta := k
  else
    delta := - k;
  Arrow2[0] := D;
  Inc(D.x, 2 * delta);
  Dec(D.y, k);
  Arrow2[1] := D;
  Inc(D.y, 2 * k);
  Arrow2[2] := D;

  with Canvas do
  begin
    if Active then
      Pen.Color := clBlue
    else
      Pen.Color := clBlack;
    MoveTo(A.x, A.y);
    LineTo(C.x, A.y);
    LineTo(C.x, B.y);
    LineTo(B.x, B.y);
    Brush.Color := clBlack;
    if LinkType and 1 <> 0 then
      Polygon(Arrow1);
    if LinkType and 2 <> 0 then
      Polygon(Arrow2);
  end;
end;

end.
