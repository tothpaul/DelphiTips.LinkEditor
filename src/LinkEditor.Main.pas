unit LinkEditor.Main;

interface
{
  DelphiTips.LinkEditor (c)2022 by Paul TOTH

  this code is free to use

  proper credits are welcome

  https://github.com/tothpaul
}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  LinkEditor.Designer;

type
  TMain = class(TForm)
    Panel1: TPanel;
    btNewTable: TButton;
    btNewField: TButton;
    Designer: TDesigner;
    procedure btNewTableClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btNewFieldClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure OnSelectTable(Sender: TObject);
  public
    { Déclarations publiques }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.btNewFieldClick(Sender: TObject);
begin
  if Designer.ActiveTable = nil then
    Exit;
  Designer.ActiveTable.AddField('Field' + Designer.ActiveTable.FieldCount.ToString);
end;

procedure TMain.btNewTableClick(Sender: TObject);
begin
  Designer.AddTable('Table' + Designer.TableCount.ToString);
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  Designer.OnSelectTable := OnSelectTable;
end;

procedure TMain.OnSelectTable(Sender: TObject);
begin
  btNewField.Enabled := Designer.ActiveTable <> nil;
end;

end.
