--
-- xmonad example config file for xmonad-0.9
--

-- Libs

-- Import stuff
import XMonad
import Data.Monoid
import qualified XMonad.StackSet as W 
import qualified Data.Map as M
import XMonad.Util.EZConfig(additionalKeys)
import System.Exit
import Graphics.X11.Xlib
import System.IO
 
 
-- actions
import XMonad.Actions.CycleWS
import XMonad.Actions.WindowGo
import qualified XMonad.Actions.Search as S
import XMonad.Actions.Search
import qualified XMonad.Actions.Submap as SM
 
-- utils
import XMonad.Util.Run(spawnPipe)
import qualified XMonad.Prompt 		as P
import XMonad.Prompt.Shell
import XMonad.Prompt
 
 
-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers
 
-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect
import XMonad.Layout.IM
import XMonad.Layout.Tabbed
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Grid
 
-- Data.Ratio for IM layout
import Data.Ratio ((%))


-- Main function 

main = do
        xmproc <- spawnPipe "xmobar"  -- start xmobar
    	xmonad 	$ withUrgencyHook NoUrgencyHook $ defaultConfig {
	
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
 
      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
 
      -- hooks, layouts
        layoutHook         = myLayoutHook,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook
   }

-- My variables

-- Terminal
myTerminal :: String
myTerminal = "urxvt"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 2

-- ModMask
myModMask :: KeyMask
myModMask = mod4Mask
myNumlockMask = mod2Mask

-- Workspaces
myWorkspaces :: [WorkspaceId]
myWorkspaces = ["main","web","im","dev","docs","media","mail","virtual","file"]

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor = "#dddddd"
myFocusedBorderColor = "#ff0000"

-- Switch to the "web" workspace
viewWeb = windows (W.greedyView "web")

-- EventHook
myEventHook = mempty

-- Startup hook
myStartupHook = return ()



-- Window rules:
myManageHook :: ManageHook
myManageHook = composeAll . concat $
    [[isFullscreen --> doFullFloat 
    , className =? "MPlayer"        --> doShift "media"
    , className =? "Gimp"           --> doShift "docs"
    , className =? "Firefox"        --> doShift "web"
    , className =? "OpenOffice.org 3.1" --> doShift "docs"
    , className =? "Evince"         --> doShift "docs"
    , className =? "Virtualbox"     --> doShift "virtual"		
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]
    ]
    where
		myIgnores = ["trayer"]
		myFloats  = []
		myOtherFloats = []

-- Status bars and logging
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }

-- Looks
 
-- Bar
customPP :: PP
customPP = defaultPP { 
     			    ppHidden = xmobarColor "#00FF00" ""
			  , ppCurrent = xmobarColor "#FF0000" "" . wrap "[" "]"
			  , ppUrgent = xmobarColor "#FF0000" "" . wrap "*" "*"
                          , ppLayout = xmobarColor "#FF0000" ""
                          , ppTitle = xmobarColor "#00FF00" "" . shorten 80
                          , ppSep = "<fc=#0033FF> | </fc>"
                     }

-- Some nice colors for the prompt windows to match the dzen status bar.
myXPConfig = defaultXPConfig                                    
    { 
	font  = "-*-terminus-*-*-*-*-12-*-*-*-*-*-*-u" 
	,fgColor = "#00FFFF"
	, bgColor = "#000000"
	, bgHLight    = "#000000"
	, fgHLight    = "#FF0000"
	, position = Top
    }
 
-- My Theme For Tabbed layout
myTheme = defaultTheme { decoHeight = 16
                        , activeColor = "#a6c292"
                        , activeBorderColor = "#a6c292"
                        , activeTextColor = "#000000"
                        , inactiveBorderColor = "#000000"
                        }

--LayoutHook
myLayoutHook  =  onWorkspace "im" chatL $  onWorkspace "web" webL  $ onWorkspace "docs" gimpL $ onWorkspace "virtual" fullL $ onWorkspace "media" fullL $ standardLayouts 
   where
	standardLayouts =   avoidStruts  $ (tiled |||  reflectTiled ||| Mirror tiled  ||| Full) 
 
        --Layouts
	tiled     = smartBorders (ResizableTall 1 (2/100) (1/2) [])
        reflectTiled = (reflectHoriz tiled)
	tabLayout = (tabbed shrinkText myTheme)
	full 	  = noBorders Full
 
	--Chat Layout
	--im = ((withIM ratio pidginRoster) $ reflectHoriz $ (withIM ratio  skypeRoster))
	chatL = avoidStruts $ smartBorders $ (withIM ratio pidginRoster) $  tiled  
	ratio = 1%9
	--roster = And (ClassName "Pidgin" ) (Role "buddy_list")
        pidginRoster    = And (ClassName "Pidgin") (Role "buddy_list")
        skypeRoster     = (ClassName "Skype") `And` (Not (Title "Options")) `And` (Not (Role "Chats")) `And` (Not (Role "CallWindowForm"))
--chatL = avoidStruts $ smartBorders $ im tiled 
 
	--Gimp Layout
	gimpL = avoidStruts $ smartBorders $ withIM (0.11) (Role "gimp-toolbox") $ reflectHoriz $ withIM (0.15) (Role "gimp-dock") Full 
 
	--Web Layout
	webL      = avoidStruts $  tabLayout  ||| tiled ||| reflectHoriz tiled |||  full 
 
        --VirtualLayout
        fullL = avoidStruts $ full




-- Key bindings. Add, modify or remove key bindings here.
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
 
    -- launch dmenu
    , ((modm, xK_p ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
 
    -- launch gmrun
    , ((modm .|. shiftMask, xK_p ), spawn "gmrun")
 
    -- close focused window
    , ((modm .|. shiftMask, xK_c ), kill)
 
     -- Rotate through the available layout algorithms
    , ((modm, xK_space ), sendMessage NextLayout)
 
    -- Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    , ((modm, xK_n ), refresh)
 
    -- Move focus to the next window
    , ((modm, xK_Tab ), windows W.focusDown)
 
    -- Move focus to the next window
    , ((modm, xK_j ), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm, xK_k ), windows W.focusUp )
 
    -- Move focus to the master window
    , ((modm, xK_m ), windows W.focusMaster )
 
    -- Swap the focused window and the master window
    , ((modm, xK_Return), windows W.swapMaster)
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j ), windows W.swapDown )
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k ), windows W.swapUp )
 
    -- Shrink the master area
    , ((modm, xK_h ), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm, xK_l ), sendMessage Expand)
 
    -- Push window back into tiling
    , ((modm, xK_t ), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm , xK_comma ), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm , xK_period), sendMessage (IncMasterN (-1)))
 
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm , xK_b ), sendMessage ToggleStruts)
 
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q ), io (exitWith ExitSuccess))
 
    -- Restart xmonad
    , ((modm , xK_q ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++
 
    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


-- Mouse bindings: default actions bound to mouse events
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
 
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
 
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


