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
  LinkEditor.Designer, System.ImageList, Vcl.ImgList;
type
  TMain = class(TForm)
    Panel1: TPanel;
    btNewEntity: TButton;
    btNewField: TButton;
    Designer: TDesigner;
    rgEntities: TRadioGroup;
    ImageList1: TImageList;
    procedure btNewEntityClick(Sender: TObject);
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
  if Designer.ActiveTable is TDesignObject then
  begin
    (Designer.ActiveTable as TDesignObject).AddField(Format('%s%u', ['CreateObject', Designer.TableCount]), 0);
  end else
    Designer.ActiveTable.AddField(Format('%s%u', ['Field', Designer.ActiveTable.FieldCount]));
end;

procedure TMain.btNewEntityClick(Sender: TObject);
begin
  case rgEntities.ItemIndex of
    0: Designer.AddEntity(eTable, 'Table' + Designer.TableCount.ToString);
    1: begin
         with Designer.AddEntity(eObject, 'Object' + Designer.TableCount.ToString) as TDesignObject do
           SetSmallImages(ImageList1);
       end;
  end;
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
