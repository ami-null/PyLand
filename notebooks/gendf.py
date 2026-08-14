import re
import numpy as np
import pandas as pd


def _seed_to_int(seed):
    if isinstance(seed, str):
        digits_only = re.sub(r"\D", "", seed)
        return int(digits_only) if digits_only else 0
    return int(seed)


def _clip(x, lo, hi):
    return np.clip(x, lo, hi)


# each theme's canonical column names, in fixed role order:
# C1 categorical (3-4 levels), C2 binary, C3/C4 numeric predictors, C5 numeric response
_THEME_COLUMNS = [
    ["Area_Type", "HeadOfHH_Gender", "Family_Size", "Monthly_Income_kBDT", "Monthly_Food_Exp_kBDT"],
    ["Study_Program", "Attends_Coaching", "Weekly_Study_Hours", "Attendance_Percent", "Exam_Score"],
    ["Area_Type", "Smoker_Status", "Daily_Sleep_Hours", "Daily_Screen_Time_Hrs", "Stress_Score"],
    ["Shop_Type", "Shop_Location", "Daily_Footfall", "Weekly_Ad_Spend_hBDT", "Daily_Sales_kBDT"],
    ["Transport_Mode", "Owns_Smartphone", "Distance_to_Work_km", "Monthly_Transport_Cost_BDT", "Commute_Time_min"],
    ["Crop_Type", "Uses_Irrigation", "Land_Size_Bigha", "Fertilizer_Used_kg", "Yield_Maund"],
    ["Sector", "Gender", "Years_of_Experience", "Weekly_Working_Hours", "Monthly_Income_kBDT"],
    ["Network_Operator", "Uses_Mobile_Banking", "Age_Years", "Daily_Internet_Hrs", "Monthly_Recharge_BDT"],
]


def _gen_theme1(rng, n, j):  # household economics
    cat = rng.choice(["Urban", "Semi-Urban", "Rural", "Slum"], size=n, p=[.35, .25, .30, .10])
    bin_ = rng.choice(["Male", "Female"], size=n, p=[.72, .28])
    fam_size = _clip(np.round(rng.normal(4.2 * j, 1.1, n)), 1, 9)
    income = _clip(np.round(15 * j + 6 * fam_size + rng.normal(0, 8, n), 1), 8, 120)
    food_exp = _clip(
        np.round(3 + 0.42 * income + 1.8 * fam_size + np.where(bin_ == "Male", 1.5, 0) + rng.normal(0, 4, n), 1),
        3, 70,
    )
    return cat, bin_, fam_size, income, food_exp


def _gen_theme2(rng, n, j):  # academic performance
    cat = rng.choice(["Science", "Business", "Arts", "Engineering"], size=n, p=[.30, .28, .17, .25])
    bin_ = rng.choice(["Yes", "No"], size=n, p=[.45, .55])
    study_hrs = _clip(np.round(rng.normal(12 * j, 4, n), 1), 1, 30)
    attendance = _clip(
        np.round(60 + 1.1 * study_hrs + np.where(bin_ == "Yes", 5, 0) + rng.normal(0, 8, n), 1), 40, 100
    )
    score = _clip(
        np.round(
            28 + 1.6 * study_hrs + 0.28 * attendance + np.where(bin_ == "Yes", 4, 0) + rng.normal(0, 7, n), 1
        ),
        20, 100,
    )
    return cat, bin_, study_hrs, attendance, score


def _gen_theme3(rng, n, j):  # health & lifestyle
    cat = rng.choice(["Urban", "Semi-Urban", "Rural"], size=n, p=[.45, .30, .25])
    bin_ = rng.choice(["Yes", "No"], size=n, p=[.22, .78])
    sleep = _clip(np.round(rng.normal(6.6 * j, 1.1, n), 1), 3.5, 10)
    screen = _clip(np.round(rng.normal(4.5 * j, 1.6, n), 1), 0.5, 12)
    stress = _clip(
        np.round(70 - 5.2 * sleep + 3.1 * screen + np.where(bin_ == "Yes", 6, 0) + rng.normal(0, 7, n), 1), 5, 100
    )
    return cat, bin_, sleep, screen, stress


def _gen_theme4(rng, n, j):  # small business / retail
    cat = rng.choice(["Grocery", "Electronics", "Clothing", "Pharmacy"], size=n, p=[.35, .2, .28, .17])
    bin_ = rng.choice(["Market", "Roadside"], size=n, p=[.55, .45])
    footfall = _clip(np.round(rng.normal(95 * j, 30, n)), 15, 260)
    ad_spend = _clip(np.round(rng.normal(18 * j, 7, n), 1), 2, 60)
    sales = _clip(
        np.round(
            2 + 0.16 * footfall + 0.55 * ad_spend + np.where(bin_ == "Market", 3, 0) + rng.normal(0, 6, n), 1
        ),
        3, 120,
    )
    return cat, bin_, footfall, ad_spend, sales


def _gen_theme5(rng, n, j):  # transportation / commute
    cat = rng.choice(["Bus", "CNG", "Rickshaw", "Walking"], size=n, p=[.4, .25, .25, .1])
    bin_ = rng.choice(["Yes", "No"], size=n, p=[.62, .38])
    distance = _clip(np.round(rng.normal(8 * j, 4, n), 1), 0.5, 30)
    cost = _clip(
        np.round(150 + 220 * distance + np.where(bin_ == "Yes", 300, 0) + rng.normal(0, 400, n), 0), 100, 8000
    )
    commute_time = _clip(np.round(8 + 3.6 * distance + 0.004 * cost + rng.normal(0, 8, n), 1), 5, 120)
    return cat, bin_, distance, cost, commute_time


def _gen_theme6(rng, n, j):  # agriculture
    cat = rng.choice(["Rice", "Jute", "Vegetables", "Wheat"], size=n, p=[.45, .15, .25, .15])
    bin_ = rng.choice(["Yes", "No"], size=n, p=[.58, .42])
    land = _clip(np.round(rng.normal(2.6 * j, 1.2, n), 2), 0.2, 8)
    fert = _clip(np.round(20 + 35 * land + np.where(bin_ == "Yes", 15, 0) + rng.normal(0, 12, n), 1), 5, 260)
    yield_ = _clip(
        np.round(3 + 6.8 * land + 0.09 * fert + np.where(bin_ == "Yes", 3, 0) + rng.normal(0, 4, n), 1), 2, 90
    )
    return cat, bin_, land, fert, yield_


def _gen_theme7(rng, n, j):  # employment / labor
    cat = rng.choice(["Garments", "Agriculture", "Service", "Informal"], size=n, p=[.3, .15, .35, .2])
    bin_ = rng.choice(["Male", "Female"], size=n, p=[.58, .42])
    exp_yrs = _clip(np.round(rng.normal(6 * j, 3.5, n), 1), 0, 25)
    hours = _clip(np.round(45 + 0.6 * exp_yrs + rng.normal(0, 6, n), 1), 20, 80)
    income = _clip(
        np.round(
            9 + 1.4 * exp_yrs + 0.18 * hours + np.where(bin_ == "Male", 3.5, 0) + rng.normal(0, 5, n), 1
        ),
        6, 90,
    )
    return cat, bin_, exp_yrs, hours, income


def _gen_theme8(rng, n, j):  # mobile / telecom usage
    cat = rng.choice(["Grameenphone", "Robi", "Banglalink", "Airtel"], size=n, p=[.42, .28, .22, .08])
    bin_ = rng.choice(["Yes", "No"], size=n, p=[.48, .52])
    age = _clip(np.round(rng.normal(27 * j, 8, n)), 15, 65)
    net_hrs = _clip(np.round(1 + 5.5 * np.exp(-((age - 22) ** 2) / 900) + rng.normal(0, 1.3, n), 1), 0.3, 10)
    recharge = _clip(
        np.round(80 + 55 * net_hrs + np.where(bin_ == "Yes", 120, 0) + rng.normal(0, 60, n), 0), 50, 1500
    )
    return cat, bin_, age, net_hrs, recharge


_THEME_GENERATORS = [
    _gen_theme1, _gen_theme2, _gen_theme3, _gen_theme4,
    _gen_theme5, _gen_theme6, _gen_theme7, _gen_theme8,
]


def random_theme_df(seed):
    """
    Generate a themed dataset, translated from an R generator that produced
    per-student assignment datasets across 8 real-world themes.

    Parameters
    ----------
    seed : int or str
        If a string is passed, all non-digit characters are stripped before
        converting to an integer.

    Returns
    -------
    pd.DataFrame with 5 columns in a fixed role order, named for whichever
    theme the seed selects:
        Column 1 : categorical, 3-4 levels
        Column 2 : binary
        Column 3 : numeric predictor
        Column 4 : numeric predictor
        Column 5 : numeric response, related to columns 2-4
    """
    seed_int = _seed_to_int(seed)
    rng = np.random.default_rng(seed_int)

    theme_idx = int(rng.integers(0, 8))
    n = int(rng.integers(100, 151))
    jitter = 1 + rng.uniform(-0.06, 0.06)

    cat, bin_, c3, c4, c5 = _THEME_GENERATORS[theme_idx](rng, n, jitter)

    df = pd.DataFrame({
        "C1": cat, "C2": bin_, "C3": c3, "C4": c4, "C5": c5,
    })
    df.columns = _THEME_COLUMNS[theme_idx]

    # shuffle row order
    shuffled_idx = rng.permutation(n)
    df = df.iloc[shuffled_idx].reset_index(drop=True)

    return df