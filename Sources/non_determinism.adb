with Ada.Text_IO; use Ada.Text_IO;

procedure Non_Determinism is
   Some_Condition : Boolean := True;

   -- select else
   task Task1 is
      entry Send_Message (Message : String);
   end Task1;
   task body Task1 is
   begin
      Put_Line ("Start of Task 1");
      select
         accept Send_Message (Message : String) do
            Put_Line ("Task 1 - got message: " & Message);
         end Send_Message;
      else
         Put_Line ("Task 1 does not have its entry called");
      end select;
      Put_Line ("End of Task 1");
   end Task1;

   -- select delay
   task Task2 is
      entry Send_Message (Message : String);
   end Task2;
   task body Task2 is
   begin
      Put_Line ("Start of Task 2");
      select
         accept Send_Message (Message : String) do
            Put_Line ("Task 2 - got message: " & Message);
         end Send_Message;
      or
         delay 1.0;
      end select;
      Put_Line ("End of Task 2");
   end Task2;

   -- select else with loop
   task Task3 is
      entry Send_Message (Message : String);
   end Task3;
   task body Task3 is
   begin
      Put_Line ("Start of Task 3");
      loop
         select
            accept Send_Message (Message : String) do
               Put_Line ("Task 3 - got message: " & Message);
            end Send_Message;
         else
            null; -- do something while waiting
         end select;
      end loop;
      Put_Line ("End of Task 3");
   end Task3;

   -- select terminate with condition
   task Task4 is
      entry Send_Message (Message : String);
   end Task4;
   task body Task4 is
   begin
      Put_Line ("Start of Task 4");
      select
         accept Send_Message (Message : String) do
            Put_Line ("Task 4 - got message: " & Message);
         end Send_Message;
      or
         when Some_Condition => terminate;
      end select;
      Put_Line ("End of Task 4");
   end Task4;

begin
   Put_Line ("Start of Main");
   delay 0.5;
   Task2.Send_Message ("Hi!"); -- call entry
   delay 0.5;
   Task3.Send_Message ("Hello!"); -- call entry
   abort Task3; -- kill task
   Put_Line ("End of Main");
end Non_Determinism;
