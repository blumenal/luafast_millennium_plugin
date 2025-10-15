import Millennium
import PluginUtils
import json
import os
from api_manager import APIManager
from luafast import luafastManager
from steam_utils import has_lua_for_app, list_lua_apps
from config import VERSION
from restart_steam import restart_steam  # Importar a função de reinício

logger = PluginUtils.Logger()

def json_response(data: dict) -> str:
    return json.dumps(data)

def success_response(**kwargs) -> str:
    return json_response({'success': True, **kwargs})

def error_response(error: str, **kwargs) -> str:
    return json_response({'success': False, 'error': error, **kwargs})

def GetPluginDir():
    current_file = os.path.realpath(__file__)
    if current_file.endswith('/main.py/main.py') or current_file.endswith('\\main.py\\main.py'):
        current_file = current_file[:-8]
    elif current_file.endswith('/main.py') or current_file.endswith('\\main.py'):
        current_file = current_file[:-8]

    if current_file.endswith('main.py'):
        backend_dir = os.path.dirname(current_file)
    else:
        backend_dir = current_file

    plugin_dir = os.path.dirname(backend_dir)
    return plugin_dir

class Plugin:
    def __init__(self):
        self.plugin_dir = GetPluginDir()
        self.backend_path = os.path.join(self.plugin_dir, 'backend')
        self.api_manager = APIManager(self.backend_path)
        self.luafast_manager = luafastManager(self.backend_path, self.api_manager)
        self._injected = False

    # SEM MAIS VERIFICAÇÃO DE API KEY
    def has_api_key(self):
        return True

    def _inject_webkit_files(self):
        if self._injected:
            return

        try:
            js_file_path = os.path.join(self.plugin_dir, '.millennium', 'Dist', 'index.js')
            if os.path.exists(js_file_path):
                Millennium.add_browser_js(js_file_path)
                self._injected = True
            else:
                logger.error(f"luafast: Bundle not found")
        except Exception as e:
            logger.error(f'luafast: Failed to inject: {e}')

    def _front_end_loaded(self):
        logger.log("luafast: v0.1.0 ready - GitHub Version")

    def _load(self):
        self._inject_webkit_files()
        Millennium.ready()

    def _unload(self):
        logger.log("Unloading luafast plugin")

_plugin_instance = None

def get_plugin():
    global _plugin_instance
    if _plugin_instance is None:
        _plugin_instance = Plugin()
        _plugin_instance._load()
    return _plugin_instance

plugin = get_plugin()

class Logger:
    @staticmethod
    def log(message: str) -> str:
        logger.log(f"[Frontend] {message}")
        return success_response()

def hasluaForApp(appid: int) -> str:
    try:
        exists = has_lua_for_app(appid)
        return success_response(exists=exists)
    except Exception as e:
        logger.error(f'hasluaForApp failed for {appid}: {e}')
        return error_response(str(e))

def addVialuafast(appid: int) -> str:
    try:
        # CHAMADA DIRETA - SEM VERIFICAÇÃO DE API
        endpoints = plugin.api_manager.get_download_endpoints()
        result = plugin.luafast_manager.add_via_lua(appid, endpoints)
        return json_response(result)
    except Exception as e:
        logger.error(f'addVialuafast failed for {appid}: {e}')
        return error_response(str(e))

def GetStatus(appid: int) -> str:
    try:
        result = plugin.luafast_manager.get_download_status(appid)
        return json_response(result)
    except Exception as e:
        logger.error(f'GetStatus failed for {appid}: {e}')
        return error_response(str(e))

def GetLocalLibrary() -> str:
    try:
        apps = list_lua_apps()
        return success_response(apps=apps)
    except Exception as e:
        logger.error(f'GetLocalLibrary failed: {e}')
        return error_response(str(e))

# FUNÇÕES DE API KEY REMOVIDAS: SetAPIKey, GetAPIKeyStatus

def removeVialuafast(appid: int) -> str:
    try:
        result = plugin.luafast_manager.remove_via_lua(appid)
        return json_response(result)
    except Exception as e:
        logger.error(f'removeVialuafast failed for {appid}: {e}')
        return error_response(str(e))

# NOVA FUNÇÃO: restartSteam
def restartSteam() -> str:
    try:
        success = restart_steam()
        if success:
            return success_response(message="Steam reiniciado com sucesso")
        else:
            return error_response("Falha ao reiniciar o Steam")
    except Exception as e:
        logger.error(f'restartSteam failed: {e}')
        return error_response(str(e))