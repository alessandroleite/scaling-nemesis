static const char * wu_version = "0.02";

#define ARRAY_SIZE(array) (sizeof(array) / sizeof(array[0]))

static const char * prog_name = "wattsup";

static const char * sysfs_path_start = "/sys/class/tty";

static char * wu_device = "ttyUSB0";
static int wu_fd = 0;
static int wu_count = 0;
static int wu_debug = 0;
static char *wu_delim = ", ";
static int wu_final = 0;
static int wu_interval = 1;
static int wu_label = 0;
static int wu_newline = 0;
static int wu_suppress = 0;

static int wu_localtime = 0;
static int wu_gmtime = 0;

static int wu_info_all = 0;
static int wu_no_data = 0;
static int wu_set_only = 0;

#define wu_strlen	256
#define wu_num_fields	18
#define wu_param_len	16

struct wu_packet {
	unsigned int	cmd;
	unsigned int	sub_cmd;
	unsigned int	count;
	char	buf[wu_strlen];
	int	len;
	char	* field[wu_num_fields];
	char	* label[wu_num_fields];
};


struct wu_data {
	unsigned int	watts;
	unsigned int	volts;
	unsigned int	amps;
	unsigned int	watt_hours;

	unsigned int	cost;
	unsigned int	mo_kWh;
	unsigned int	mo_cost;
	unsigned int	max_watts;

	unsigned int	max_volts;
	unsigned int	max_amps;
	unsigned int	min_watts;
	unsigned int	min_volts;

	unsigned int	min_amps;
	unsigned int	power_factor;
	unsigned int	duty_cycle;
	unsigned int	power_cycle;
};

struct wu_options 
{
	char	* longopt;
	int	shortopt;
	int	param;
	int	flag;
	char	* value;

	char	* descr;
	char	* option;
	char	* format;

	int	(*show)(int dev_fd);
	int	(*store)(int dev_fd);
};

enum {
	wu_option_help = 0,
	wu_option_version,

	wu_option_debug,

	wu_option_count,
	wu_option_final,

	wu_option_delim,
	wu_option_newline,
	wu_option_localtime,
	wu_option_gmtime,
	wu_option_label,

	wu_option_suppress,

	wu_option_cal,
	wu_option_header,

	wu_option_interval,
	wu_option_mode,
	wu_option_user,

	wu_option_info_all,
	wu_option_no_data,
	wu_option_set_only,
};


static char * wu_option_value(unsigned int index);


enum {
	wu_field_watts		= 0,
	wu_field_volts,
	wu_field_amps,

	wu_field_watt_hours,
	wu_field_cost,
	wu_field_mo_kwh,
	wu_field_mo_cost,

	wu_field_max_watts,
	wu_field_max_volts,
	wu_field_max_amps,

	wu_field_min_watts,
	wu_field_min_volts,
	wu_field_min_amps,

	wu_field_power_factor,
	wu_field_duty_cycle,
	wu_field_power_cycle,
};

struct wu_field {
	unsigned int	enable;
	char		* name;
	char		* descr;
};

static struct wu_field wu_fields[wu_num_fields] = {
	[wu_field_watts]	= {
		.name	= "watts",
		.descr	= "Watt Consumption",
	},

	[wu_field_min_watts]	= {
		.name	= "min-watts",
		.descr	= "Minimum Watts Consumed",
	},

	[wu_field_max_watts]	= {
		.name	= "max-watts",
		.descr	= "Maxium Watts Consumed",
	},

	[wu_field_volts]	= {
		.name	= "volts",
		.descr	= "Volts Consumption",
	},

	[wu_field_min_volts]	= {
		.name	= "max-volts",
		.descr	= "Minimum Volts Consumed",
	},

	[wu_field_max_volts]	= {
		.name	= "min-volts",
		.descr	= "Maximum Volts Consumed",
	},

	[wu_field_amps]		= {
		.name	= "amps",
		.descr	= "Amp Consumption",
	},

	[wu_field_min_amps]	= {
		.name	= "min-amps",
		.descr	= "Minimum Amps Consumed",
	},

	[wu_field_max_amps]	= {
		.name	= "max-amps",
		.descr	= "Maximum Amps Consumed",
	},

	[wu_field_watt_hours]	= {
		.name	= "kwh",
		.descr	= "Average KWH",
	},

	[wu_field_mo_kwh]	= {
		.name	= "mo-kwh",
		.descr	= "Average monthly KWH",
	},

	[wu_field_cost]		= {
		.name	= "cost",
		.descr	= "Cost per watt",
	},

	[wu_field_mo_cost]	= {
		.name	= "mo-cost",
		.descr	= "Monthly Cost",
	},

	[wu_field_power_factor]	= {
		.name	= "power-factor",
		.descr	= "Ratio of Watts vs. Volt Amps",
	},

	[wu_field_duty_cycle]	= {
		.name	= "duty-cycle",
		.descr	= "Percent of the Time On vs. Time Off",
	},

	[wu_field_power_cycle]	= {
		.name	= "power-cycle",
		.descr	= "Indication of power cycle",
	},

};

static int wu_start_log(void);
int set_energy_counter(int argc, char ** argv);
float get_consumed_energy();
