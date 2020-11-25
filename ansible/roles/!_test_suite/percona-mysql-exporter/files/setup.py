from setuptools import setup, find_packages

setup(
    name='prometheus-mysql-exporter',
    version='0.2.0.dev1',
    description='MySQL query Prometheus exporter',
    url='https://github.com/Braedon/prometheus-mysql-exporter',
    author='Braedon Vickers',
    author_email='braedon.vickers@gmal.com',
    license='MIT',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'Topic :: System :: Monitoring',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
    ],
    keywords='monitoring prometheus exporter mysql',
    packages=find_packages(exclude=['tests']),
    install_requires=[
        'mysqlclient',
        'prometheus-client'
    ],
    entry_points={
        'console_scripts': [
            'prometheus-mysql-exporter=prometheus_mysql_exporter:main',
        ],
    },
)
