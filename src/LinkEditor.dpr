program LinkEditor;

uses
  Vcl.Forms,
  LinkEditor.Main in 'LinkEditor.Main.pas' {Main},
  LinkEditor.Designer in 'LinkEditor.Designer.pas' {Designer: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
