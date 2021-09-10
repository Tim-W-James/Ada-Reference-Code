with Ada.Text_IO; use Ada.Text_IO;

procedure sample is
   -- ================
   -- VARIABLES
   -- ================
   Const : constant Integer := 3;
   Var   :          Positive := 5;

   -- ================
   -- TYPES
   -- ================
   type My_Range is range 1 .. 5; -- inclusive
   Mod_Size : constant Positive := 5;
   type Modular_Element is mod Mod_Size;
   type My_Array is array (My_Range) of Positive; -- array with index 1 .. 5;
   Array_Instance : My_Array := (1, 2, 3, 4, 5);

   -- ================
   -- FUNCTIONS
   -- ================
   -- have return values, should be side effect free aka pure
   function Increment_By
     (X    : Integer := 0; -- parameters, can have default values
      Incr : Integer := 1) return Integer is
   begin
      return X + Incr;
   end Increment_By;
   -- calls
   -- Var := Increment_By; -- parameterless, uses default values
   -- Var := Increment_By (1, 3); -- regular parameter passing
   -- Var := Increment_by (X => 3); -- named parameter passing

   -- single line definition for boolean
   function isGreaterThanTen (X : Integer) return Boolean is
     (X > 10);

   -- ================
   -- PROCEDURE
   -- ================
   -- must define parameter modes:
   -- * in     : parameter can only be read, not written (default)
   -- * out    : parameter can only be written to, then read
   -- * in out : parameter can be both read and written
   procedure Add_Ten (X : in out Integer) is
      type iter is range 1 .. 10;
   begin
      for I in iter loop
         X := X + 1;
      end loop;
   end Add_Ten;

   -- ================
   -- TASKS
   -- ================
   -- static task, only needs to be declared to be instantiated, runs on parent begin
   task Static_Task;
   task body Static_Task is
   begin
      delay 1.0; -- note: delay until x; is more precise. delay 0.0; to signal CPU to schedule in a different thread.
      Put_Line ("Start of Static Task");
   end Static_Task;

   -- task type, used to create multiple instances, must be instantiated separately
   task type Task_Type (Id : Positive);
   task body Task_Type is
   begin
      delay 1.0;
      Put_Line ("Start of Task Type " & Positive'Image (Id));
   end Task_Type;
   -- allocation
   Task_1_Instance : Task_Type (1);
   Task_2_Instance : Task_Type (2);
   -- Task_Array : array (1 .. 10) of Task_Type (3);

   -- dynamic task type
   task type Dynamic_Task_Type (Id : Positive);
   -- tasks are bound to the scope where pointer is declared, between type declaration and allocation
   -- note: the task itself can last longer than its pointer
   type Dynamic_Task_Type_Pointer is access Dynamic_Task_Type;
   task body Dynamic_Task_Type is
   begin
      delay 1.0;
      Put_Line ("Start of Dynamic Task Type " & Positive'Image (Id));
   end Dynamic_Task_Type;
   -- allocation, use new for dynamic tasks
   Dynamic_Task : Dynamic_Task_Type_Pointer := new Dynamic_Task_Type (1);

   -- tasks can be nested, in this case Nested_Task is the parent
   task Nested_Task;
   task body Nested_Task is
   begin
      delay 1.0;
      Put_Line ("Start of Nested Task");
      declare -- can also have additional declare blocks after begin
         -- allocation of another task (doesn't necessarily need to be dynamic)
         Inner_Task : Dynamic_Task_Type_Pointer := new Dynamic_Task_Type (2);
      begin
         Put_Line ("End of Nested Task Declare");
      end;
   end Nested_Task;

   -- task synchronization: rendez-vous
   task Sync_Task is
      entry Continue; -- define an entry (note: different to protected entry)
   end Sync_Task;
   task body Sync_Task is
   begin
      Put_Line ("Start of Sync Task");
      accept Continue; -- task will wait until the entry is called
      Put_Line ("End of Sync Task");
   end Sync_Task;

   -- ================
   -- PROTECTED OBJECTS
   -- ================
   -- enforce protected operations for mutex on shared resources to avoid race conditions, etc.
   protected Protected_Obj is
      procedure Set (V : Modular_Element);
      function Get return Modular_Element;

      entry Inc;
      entry Dec;
   private -- information hiding
      Local : Modular_Element := 0;
   end Protected_Obj;

   protected body Protected_Obj is
      -- procedures can modify data, only 1 protected object can access at a time
      procedure Set (V : Modular_Element) is
      begin
         Local := V;
      end Set;

      -- functions cannot modify data, can be called in parallel
      function Get return Modular_Element is
      begin
         return Local;
      end Get;

      -- entries create barriers that are only passed when the condition evaluates to True
      -- note: different to task entries
      entry Inc when Local < Modular_Element'Last is
      begin
         Local := Modular_Element'Succ (Local);
      end Inc;

      entry Dec when Local > Modular_Element'First is
      begin
         Local := Modular_Element'Pred (Local);
      end Dec;
   end Protected_Obj;
   -- protected types are similar to task types

-- main
begin
   -- example print statements
   Put_Line ("Start of main scope");
   Put_Line (Integer'Image (Const)); -- use [type]'Image to print

   -- imperative
   Add_Ten (Var); -- procedure call
   -- Var := 10; -- assignment
   if isGreaterThanTen (Var) then
      Put_Line ("Var is > 10");
   elsif not isGreaterThanTen (Var) then
      Put_Line ("Var is <= 10");
   else
      Put_Line ("How did you get here???");
   end if;
   -- use 'and then' for lazy evaluation (will not evaluate second expression if first is False)
   if False and then True then
      null;
   end if;
   -- use 'or else' for lazy evaluation (will not evaluate second expression if first is True)
   if True or else False then
      null;
   end if;
   -- example for loop can be found in procedures

   -- task synchronization usage
   delay 3.0;
   Sync_Task.Continue; -- call Sync_Task's entry

   -- protected object usage
   delay 1.0;
   Protected_Obj.Set (3); -- only 1 thread can be inside a protected procedure at a time
   Protected_Obj.Inc;     -- entry will wait until condition is True
   Put_Line ("Protect Obj number is: " & Modular_Element'Image (Protected_Obj.Get));

   null;

end sample;
