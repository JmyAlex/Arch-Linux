--xmonad.hs
--

-- Import stuff
import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
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
import qualified XMonad.Prompt         as P
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
 
--Terminal
myTerminal :: String
myTerminal      = "urxvt"
 
-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
 
-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth   = 2
 
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask :: KeyMask
myModMask       = mod4Mask
 
-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask
 
-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces :: [WorkspaceId]
myWorkspaces    = ["main","web","im","dev","docs","media","mail","virtual","file"]
 
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"
 
------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
 
    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
 
    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")
 
    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)
 
     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)
 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)
 
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
 
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
 
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
 
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
 
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
 
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
 
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
 
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
 
    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
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
 
 
------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
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
 
------------------------------------------------------------------------
-- Layouts:
 
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- Instead use the 'ewmh' function from that module to modify your
-- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--myLayout = tiled ||| Mirror tiled ||| Full
  --where
    -- default tiling algorithm partitions the screen into two panes
    --tiled   = Tall nmaster delta ratio
 
    -- The default number of windows in the master pane
    --nmaster = 1
 
    -- Default proportion of screen occupied by master pane
    --ratio   = 1/2
 
    -- Percent of screen to increment by when resizing panes
    --delta   = 3/100
 
------------------------------------------------------------------------
-- Window rules:
 
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook :: ManageHook
myManageHook = composeAll . concat $
    [[isFullscreen                  --> doFullFloat
    , className =? "MPlayer"        --> doShift "media"
    , className =? "Gimp"           --> doShift "docs"
    , className =? "OpenOffice.org 3.1" -->doShift "docs"
    , className =? "Evince"         --> doShift "docs"
    , className =? "VirtualBox"     --> doShift "virtual"
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]
    ]
    where
            myIgnores = ["trayer"]
            myFloats  = []
            myOtherFloats = []
 
------------------------------------------------------------------------
-- Event handling
 
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
myEventHook = mempty
 
------------------------------------------------------------------------
-- Status bars and logging
 
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
--myLogHook = return ()
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }

 
------------------------------------------------------------------------
-- Startup hook
 
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
myStartupHook = return ()
 
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
 
-- Run xmonad with the settings you specify. No need to modify this.
--
--main = xmonad defaults
 
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
--defaults = defaultConfig {
main = do
        xmproc <- spawnPipe "xmobar"  -- start xmobar
        xmonad  $ withUrgencyHook NoUrgencyHook $ defaultConfig
    
      -- simple stuff
        	{  terminal           = myTerminal
        	 , focusFollowsMouse  = myFocusFollowsMouse
         	 , borderWidth        = myBorderWidth
        	 , modMask            = myModMask
        	 , numlockMask        = myNumlockMask
        	 , workspaces         = myWorkspaces
        	 , normalBorderColor  = myNormalBorderColor
       	 	 , focusedBorderColor = myFocusedBorderColor
 
      -- key bindings
        	 , keys               = myKeys
        	 , mouseBindings      = myMouseBindings
 
      -- hooks, layouts
        	 , layoutHook         = myLayoutHook
        	 , manageHook         = myManageHook
        	 , handleEventHook    = myEventHook
        	 , logHook            = myLogHook xmproc
        	 , startupHook        = myStartupHook
       		 }



---- Looks --
---- bar
customPP :: PP
customPP = defaultPP {
                            ppHidden = xmobarColor "#00FF00" ""
                          , ppCurrent = xmobarColor "#FF0000" "" . wrap "[" "]"
                          , ppUrgent = xmobarColor "#FF0000" "" . wrap "*" "*"
                          , ppLayout = xmobarColor "#FF0000" ""
                          , ppTitle = xmobarColor "#00FF00" "" . shorten 80
                          , ppSep = "<fc=#0033FF> | </fc>"
                     }
 
-- some nice colors for the prompt windows to match the dzen status bar.
myXPConfig = defaultXPConfig                                   
    {
        font  = "-*-terminus-*-*-*-*-12-*-*-*-*-*-*-u"
        ,fgColor = "#00FFFF"
        , bgColor = "#000000"
        , bgHLight    = "#000000"
        , fgHLight    = "#FF0000"
        , position = Top
    }
 
--- My Theme For Tabbed layout
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
   	full       = noBorders Full
 
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