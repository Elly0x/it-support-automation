"""
ping_sweep.py

Varredura simples de rede: verifica quais IPs de uma faixa local
estão ativos, usando ping. Útil para diagnóstico rápido de suporte
(ex: "quais máquinas do setor estão ligadas e respondendo na rede?").

Uso:
    python ping_sweep.py 192.168.1

    (o script varre 192.168.1.1 até 192.168.1.254)

Compatível com Windows, Linux e macOS.
"""

import subprocess
import platform
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed


def host_esta_ativo(ip: str) -> bool:
    """Envia 1 pacote de ping para o IP e retorna True se houve resposta."""
    sistema = platform.system().lower()
    if sistema == "windows":
        comando = ["ping", "-n", "1", "-w", "500", ip]
    else:
        comando = ["ping", "-c", "1", "-W", "1", ip]

    resultado = subprocess.run(
        comando,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return resultado.returncode == 0


def varrer_rede(prefixo: str, inicio: int = 1, fim: int = 254) -> list[str]:
    """Varre prefixo.inicio até prefixo.fim em paralelo e retorna os IPs ativos."""
    ips_ativos = []
    enderecos = [f"{prefixo}.{i}" for i in range(inicio, fim + 1)]

    print(f"Varrendo {prefixo}.{inicio} até {prefixo}.{fim} ...\n")

    with ThreadPoolExecutor(max_workers=50) as executor:
        futuros = {executor.submit(host_esta_ativo, ip): ip for ip in enderecos}
        for futuro in as_completed(futuros):
            ip = futuros[futuro]
            try:
                if futuro.result():
                    print(f"[ATIVO]   {ip}")
                    ips_ativos.append(ip)
            except Exception as erro:
                print(f"[ERRO]    {ip} -> {erro}")

    return sorted(ips_ativos, key=lambda x: int(x.split(".")[-1]))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python ping_sweep.py <prefixo_da_rede>")
        print("Exemplo: python ping_sweep.py 192.168.1")
        sys.exit(1)

    prefixo_rede = sys.argv[1]
    ativos = varrer_rede(prefixo_rede)

    print(f"\nTotal de hosts ativos encontrados: {len(ativos)}")
    for ip in ativos:
        print(f"  - {ip}")
