from typing import Optional
import PluginUtils

logger = PluginUtils.Logger()

class APIManager:
    def __init__(self, backend_path: str):
        self.backend_path = backend_path
        self.repositories = [
            'dvahana2424-web/sojogamesdatabase1',
            'SPIN0ZAi/SB_manifest_DB'
        ]

    def get_download_endpoints(self) -> list:
        return self.repositories  # Agora retorna lista de repositórios
