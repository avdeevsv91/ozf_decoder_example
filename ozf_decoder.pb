;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example of OZF decoder
;; Author: SoulTaker (https://github.com/thesoultaker48/)
;; DLL library: https://github.com/thesoultaker48/ozf_decoder_dll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Open DLL library
If OpenLibrary(0, "ozf_decoder.dll")
  
  ; Select OZF file
  file$ = OpenFileRequester("Select OZF file...", "", "OZF file (*.ozf2, *.ozfx3)|*.ozf2;*.ozfx3|All files (*.*)|*.*", 0)
  If Len(file$) = 0
    End
  EndIf
  
  ; Open OZF file
  *OZF = CallCFunction(0, "ozf_open", @file$)
  
  If *OZF
    
    ; Get number of scales
    num_scales = CallCFunction(0, "ozf_num_scales", *OZF)
    scale = Val(InputRequester("Input scale...", "Value (0-"+Str(num_scales)+"):", Str(Int(num_scales/2))))
    
    If scale<0
      scale = 0
    ElseIf scale>num_scales
      scale = num_scales
    EndIf
    
    ; Get number of tiles for current scale
    num_tiles_per_x = CallCFunction(0, "ozf_num_tiles_per_x", *OZF, scale)
    num_tiles_per_y = CallCFunction(0, "ozf_num_tiles_per_y", *OZF, scale)

    ; Create image
    If CreateImage(0, num_tiles_per_x*64+1, num_tiles_per_y*64+1)
      If StartDrawing(ImageOutput(0))

        ; Drawing all tiles
        For tiles_per_y=0 To num_tiles_per_y - 1
          For tiles_per_x=0 To num_tiles_per_x - 1
            
            ; Get current tile
            *MemoryBuffer = AllocateMemory(64*64*4)
            CallCFunction(0, "ozf_get_tile", *OZF, scale, tiles_per_x, tiles_per_y, *MemoryBuffer)
            
            ; Drawing current tile
            For i=0 To 64*64*4-1 Step 4
              y = Round(i/64/4, #PB_Round_Down)
              x = i/4 - y*64
              
              ; Get pixel color
              R = PeekB(*MemoryBuffer + i + 0)
              G = PeekB(*MemoryBuffer + i + 1)
              B = PeekB(*MemoryBuffer + i + 2)
              A = PeekB(*MemoryBuffer + i + 3)
              
              ; Draw pixel
              Plot(tiles_per_x * 64 + x, tiles_per_y * 64 + y, RGBA(R, G, B, A))
              
              ; Draw lines
              ;Line(0, tiles_per_y * 64, num_tiles_per_x*64, 1, RGB(255, 0, 0))
              ;Line(tiles_per_x * 64, 0, 1, num_tiles_per_y*64, RGB(255, 0, 0))
            Next i

            ; Free tile memory
            FreeMemory(*MemoryBuffer)
            
          Next tiles_per_x
        Next tiles_per_y
        
        ; Draw last lines
        ;Line(0, (tiles_per_y) * 64, num_tiles_per_x*64, 1, RGB(255, 0, 0))
        ;Line(tiles_per_x * 64, 0, 1, num_tiles_per_y*64, RGB(255, 0, 0))
        
        ; Stop drawing
        StopDrawing()
      EndIf
    EndIf
    
    ; Close OZF library
    *OZF = CallCFunction(0, "ozf_close", *OZF)
    CloseLibrary(0)
    
    ; Create window and display image
    OpenWindow(0, #PB_Ignore, #PB_Ignore, 800, 600, "OZF Drawing Test (Scale: "+Str(scale)+", Tiles: "+Str(num_tiles_per_x)+"x"+Str(num_tiles_per_y)+", Size: "+Str(num_tiles_per_x*64)+"x"+Str(num_tiles_per_y*64)+")", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
    ScrollAreaGadget(1, 0, 0, 800, 600, num_tiles_per_x*64+1, num_tiles_per_y*64+1, 10)
    ImageGadget(0, 0, 0, 0, 0, ImageID(0))
    Repeat
      Event = WaitWindowEvent() 
    Until Event = #PB_Event_CloseWindow
    
  Else
    MessageRequester("Error", "Can`t open OZF file!", #MB_ICONWARNING)
  EndIf
  
Else
  MessageRequester("Error", "Can`t load ozf_decoder.dll!", #MB_ICONERROR)
EndIf

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 3
; EnableXP